# frozen_string_literal: true

require "rails_helper"

def transform_tree(nodes, &block)
  output = []
  nodes.each do |node|
    output << yield(node)
    output << transform_tree(node.children, &block) if node.children.any?
  end
  output
end

RSpec.describe Katalyst::Navigation::Menu do
  subject(:menu) { create :katalyst_navigation_menu, items: items }

  let(:first) { build :katalyst_navigation_link, title: "First", url: "/first" }
  let(:last) { build :katalyst_navigation_link, title: "Last", url: "/last" }
  let(:items) { [first, last] }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:slug).ignoring_case_sensitivity }

  it { expect(menu.items).to eq(items) }

  it { is_expected.to have_attributes(state: :published) }
  it { expect(menu.draft_version).to eq(menu.published_version) }

  it "stores the expect json (id/depth but no index)" do
    expect(menu.published_nodes.as_json).to eq([{ id: first.id, depth: 0 }.as_json,
                                                { id: last.id, depth: 0 }.as_json])
  end

  it { expect(menu.published_items).to eq(items) }
  it { expect(menu.published_tree).to eq(items) }

  describe "#destroy" do
    before { menu }

    it "deletes versions" do
      expect { menu.destroy! }.to change(Katalyst::Navigation::Menu::Version, :count).to(0)
    end

    it "deletes items" do
      expect { menu.destroy! }.to change(Katalyst::Navigation::Link, :count).to(0)
    end
  end

  shared_examples "an un-versioned change" do
    it "does not change state" do
      expect { update }.not_to change(menu, :state)
    end

    it "does not change versions" do
      expect { update }.not_to change(menu, :draft_version)
    end
  end

  describe "#title=" do
    let(:update) { menu.update(title: "Updated") }

    it_behaves_like "an un-versioned change"

    it { expect { update }.to change(menu, :title) }
  end

  describe "#slug=" do
    let(:update) { menu.update(slug: "updated") }

    it_behaves_like "an un-versioned change"

    it { expect { update }.to change(menu, :slug) }
  end

  shared_examples "a versioned change" do
    it "changes state" do
      expect { update }.to change(menu, :state).from(:published).to(:draft)
    end

    it "creates a new version" do
      expect { update }.to change(menu, :draft_version)
    end

    it "does not publish the new version" do
      expect { update }.not_to change(menu, :published_version)
    end
  end

  describe "add link" do
    let(:update) do
      update = create :katalyst_navigation_link, menu: menu, title: "Update", url: "/update"
      menu.update(items_attributes: menu.draft_nodes + [{ id: update.id }])
    end

    it_behaves_like "a versioned change"

    it "adds item" do
      expect { update }.to change { transform_tree(menu.reload.draft_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/first /last /update])
    end

    context "with controller formatted attributes" do
      let(:update) do
        update     = create :katalyst_navigation_link, menu: menu, title: "Update", url: "/update"
        attributes = { "0" => { id: first.id.to_s, index: "0", depth: "0" },
                       "1" => { id: update.id.to_s, index: "2", depth: "0" },
                       "2" => { id: last.id.to_s, index: "1", depth: "0" } }
        menu.update(items_attributes: attributes)
      end

      it "adds item" do
        expect { update }.to change { transform_tree(menu.reload.draft_tree, &:url) }
                               .from(%w[/first /last])
                               .to(%w[/first /last /update])
      end
    end
  end

  describe "remove link" do
    let(:update) do
      menu.update(items_attributes: menu.draft_nodes.take(1))
    end

    it_behaves_like "a versioned change"

    it "removes item" do
      expect { update }.to change { transform_tree(menu.reload.draft_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/first])
    end
  end

  describe "swap two items" do
    let(:update) do
      update = create :katalyst_navigation_link, menu: menu, title: "Update", url: "/update"
      menu.update(items_attributes: [{ id: first.id },
                                     { id: update.id }])
    end

    it_behaves_like "a versioned change"

    it "changes item" do
      expect { update }.to change { transform_tree(menu.reload.draft_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/first /update])
    end
  end

  describe "reorder items" do
    let(:update) do
      menu.update(items_attributes: [{ id: last.id },
                                     { id: first.id }])
    end

    it_behaves_like "a versioned change"

    it "changes order" do
      expect { update }.to change { transform_tree(menu.reload.draft_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/last /first])
    end
  end

  describe "change depth" do
    let(:update) do
      menu.update(items_attributes: [{ id: first.id, depth: 0 },
                                     { id: last.id, depth: 1 }])
    end

    it_behaves_like "a versioned change"

    it "changes nesting" do
      expect { update }.to change { transform_tree(menu.reload.draft_tree, &:url) }
                             .from(%w[/first /last])
                             .to(["/first", ["/last"]])
    end
  end

  describe "#publish!" do
    let(:item_attributes) { menu.draft_nodes.take(1) }

    before do
      menu.update(items_attributes: item_attributes)
    end

    it "changes published version" do
      published = menu.published_version
      draft     = menu.draft_version
      expect { menu.publish! }.to change(menu, :published_version).from(published).to(draft)
    end

    it "removes orphaned version" do
      expect { menu.publish! }.to change(Katalyst::Navigation::Menu::Version, :count).by(-1)
    end

    it "removes orphaned published version" do
      published = menu.published_version
      menu.publish!
      expect(Katalyst::Navigation::Menu::Version.find_by(id: published.id)).to be_nil
    end

    it "doesn't remove orphaned link" do
      expect { menu.publish! }.not_to change(Katalyst::Navigation::Link, :count)
    end

    context "when orphaned links for more than 1 day" do
      before do
        travel 1.day
      end

      it { expect { menu.publish! }.to change(Katalyst::Navigation::Link, :count).by(-1) }

      it "removes the correct link" do
        link_id = menu.draft_items.map(&:id) - menu.published_items.map(&:id)
        menu.publish!
        expect(Katalyst::Navigation::Link.find_by(id: link_id.first)).to be_nil
      end
    end
  end

  describe "#revert!" do
    let(:item_attributes) { menu.draft_nodes.take(1) }

    before do
      menu.update(items_attributes: item_attributes)
    end

    it "changes draft version" do
      published = menu.published_version
      draft     = menu.draft_version
      expect { menu.revert! }.to change(menu, :draft_version).from(draft).to(published)
    end

    it "removes orphaned version" do
      expect { menu.revert! }.to change(Katalyst::Navigation::Menu::Version, :count).by(-1)
    end

    it "removes orphaned draft version" do
      draft = menu.draft_version
      menu.revert!
      expect(Katalyst::Navigation::Menu::Version.find_by(id: draft.id)).to be_nil
    end

    it "does not remove links" do
      travel 1.day
      expect { menu.revert! }.not_to change(Katalyst::Navigation::Link, :count)
    end

    context "with multiple link changes" do
      let(:multiple_links) { create_list :katalyst_navigation_link, 2, menu: menu }
      let(:item_attributes) { [{ id: multiple_links.first.id, depth: 0 }, { id: multiple_links.last.id, depth: 1 }] }

      before do
        travel 1.day
      end

      it { expect { menu.revert! }.to change(Katalyst::Navigation::Link, :count).by(-2) }

      it "removes updated link" do
        menu.revert!
        expect(Katalyst::Navigation::Link.where(id: multiple_links.map(&:id))).to be_empty
      end
    end
  end
end
