import { types, getParent } from "mobx-state-tree";
import axios from "axios";

const Meal = types
  .model("Meal", {
    title: "",
    start: "",
    url: "",
    description: ""
  })
  .views(self => ({
    get form() {
      return getParent(this, 2);
    }
  }))
  .actions(self => ({}));

export default Meal;
