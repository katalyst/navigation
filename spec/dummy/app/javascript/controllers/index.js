import { application } from "controllers/application"

import navigation from "@katalyst/navigation";
application.load(navigation);

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
