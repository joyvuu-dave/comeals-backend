import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";

const Event = types
  .model("Event", {
    id: types.identifier()
  })
  .views(self => ({}))
  .actions(self => ({}));

export default Event;
