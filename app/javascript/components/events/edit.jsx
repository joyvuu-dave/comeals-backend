import React from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";

class EventsEdit extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    axios
      .patch(`${window.host}api.comeals${window.topLevel}/api/v1/events`, {
        title: values.title,
        description: values.description,
        day: values.day,
        start: values.start,
        end: values.end,
        all_day: values.all_day
      })
      .then(function(response) {
        if (response.status === 200) {
          window.location.href = `${window.host}admin.comeals${window.topLevel}`;
        }
      })
      .catch(function(error) {
        if (error.response) {
          // The request was made and the server responded with a status code
          // that falls out of the range of 2xx
          const data = error.response.data;
          const status = error.response.status;
          const headers = error.response.headers;

          window.alert(data.message);
        } else if (error.request) {
          // The request was made but no response was received
          // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
          // http.ClientRequest in node.js
          const request = error.request;
        } else {
          // Something happened in setting up the request that triggered an Error
          const message = error.message;
        }
        const config = error.config;
      });
  }

  render() {
    return (
      <div>
        <div className="flex">
          <h2 className="mar-md">Event</h2>
          <button type="button" className="mar-md button-warning">Delete</button>
        </div>
        <fieldset className="w-50">
          <legend>Edit</legend>
          <LocalForm
            onUpdate={form => this.handleUpdate(form)}
            onChange={values => this.handleChange(values)}
            onSubmit={values => this.handleSubmit(values)}
          >
            <label>Title</label>
            <Control.text model=".title" className="w-75" />
            <br />

            <label>Description</label>
            <Control.textarea model=".description" className="w-75" placeholder="optional" />
            <br />

            <label>Day</label>
            <Control.input type="date" model=".day" className="w-75" />
            <br />

            <label>Start Time</label>
            <Control.input type="time" model=".start" className="w-75" />
            <br />

            <label>End Time</label>
            <Control.input type="time" model=".end" className="w-75" />
            <br />

            <label>All Day</label>
            <Control.input type="checkbox" model=".all_day" className="w-75" />
            <br />

            <button type="submit" className="button-dark">Update</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default EventsEdit;
