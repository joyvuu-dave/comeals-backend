import { types, getParent } from "mobx-state-tree";
import Meal from "./meal";

const MealStore = types
  .model("MealStore", { bills: types.map(Meal) })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }));

export default MealStore;
