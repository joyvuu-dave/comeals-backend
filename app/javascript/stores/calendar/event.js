import { types, getParent } from "mobx-state-tree";
import axios from "axios";

const Event = types
  .model("Event", {
    title: "",
    start: "",
    end: "",
    url: "",
    description: ""
  })
  .views(self => ({
    get form() {
      return getParent(this, 2);
    }
  }))
  .actions(self => ({}));

export default Event;
