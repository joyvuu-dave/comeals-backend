import React from "react";
import { LocalForm, Control, actions } from "react-redux-form";
import axios from "axios";

class GuestRoomReservationsEdit extends React.Component {
  handleSubmit(values) {
    axios
      .patch(`${window.host}api.comeals${window.topLevel}/api/v1/guest-room-reservations/${this.props.event.id}/update`, {
        resident_id: values.resident_id,
        date: values.day
      })
      .then(function(response) {
        if (response.status === 200) {
          window.location.href = `${window.host}${window.slug}.comeals${window.topLevel}/calendar`;
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

  handleDelete() {
    if(window.confirm("Do you really want to delete this reservation?")) {
      axios
        .delete(`${window.host}api.comeals${window.topLevel}/api/v1/guest-room-reservations/${this.props.event.id}/delete`)
        .then(function(response) {
          if (response.status === 200) {
            window.location.href = `${window.host}${window.slug}.comeals${window.topLevel}/calendar`;
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
  }

  render() {
    return (
      <div>
        <div className="flex">
          <h2 className="mar-md">Guest Room Reservation</h2>
          <button onClick={this.handleDelete.bind(this)} type="button" className="mar-md button-warning">Delete</button>
        </div>
        <fieldset className="w-50">
          <legend>Edit</legend>
          <LocalForm
            onSubmit={values => this.handleSubmit(values)}
            initialState={{resident_id: this.props.event.resident_id, day: this.props.event.date}}
          >
            <label>Host</label>
            <Control.select model=".resident_id" id="local.resident_id" className="w-75">
              {this.props.hosts.map(host => (
                <option key={host[0]} value={host[0]}>{host[2]} - {host[1]}</option>
              ))}
            </Control.select>
            <br />

            <label>Day</label>
            <Control type="date" model=".day" id="local.day" className="w-75" />
            <br />

            <button type="submit" className="button-dark">Update</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default GuestRoomReservationsEdit;
