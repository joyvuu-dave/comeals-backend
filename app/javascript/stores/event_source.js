import { types } from "mobx-state-tree";

const EventSource = types.model("EventSource", {
  url: types.string,
  color: types.maybe(types.string)
});

export default EventSource;
