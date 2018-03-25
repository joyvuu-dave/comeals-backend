import React from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";

class CommonHouseReservationsEdit extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    if(values.start_time > values.end_time) {
      window.alert('Start time cannot be later than end time')
      return
    }

    axios
      .patch(`${window.host}api.comeals${window.topLevel}/api/v1/common-house-reservations/${this.props.event.id}/update`, {
        resident_id: values.resident_id,
        start_year: values.day && values.day.split("-")[0],
        start_month: values.day && values.day.split("-")[1],
        start_day: values.day && values.day.split("-")[2],
        start_hours: values.start_time && values.start_time.split(":")[0],
        start_minutes: values.start_time && values.start_time.split(":")[1],
        end_hours: values.end_time && values.end_time.split(":")[0],
        end_minutes: values.end_time && values.end_time.split(":")[1]
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
        .delete(`${window.host}api.comeals${window.topLevel}/api/v1/common-house-reservations/${this.props.event.id}/delete`)
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
          <h2 className="mar-md">Common House Reservation</h2>
          <button onClick={this.handleDelete.bind(this)} type="button" className="mar-md button-warning">Delete</button>
        </div>
        <fieldset className="w-50">
          <legend>Edit</legend>
          <LocalForm
            onSubmit={values => this.handleSubmit(values)}
            initialState={{
              resident_id: this.props.event.resident_id,
              day: `${new Date(this.props.event.start_date).getFullYear()}-${new Date(this.props.event.start_date).getMonth() < 9 ? `0${(new Date(this.props.event.start_date).getMonth() + 1)}` : new Date(this.props.event.start_date).getMonth() + 1}-${new Date(this.props.event.start_date).getDate()}`,
              start_time: `${new Date(this.props.event.start_date).getUTCHours()}:${new Date(this.props.event.start_date).getUTCMinutes()}`,
              end_time: `${new Date(this.props.event.end_date).getUTCHours()}:${new Date(this.props.event.end_date).getUTCMinutes() < 10 ? `0${new Date(this.props.event.end_date).getMinutes()}` : new Date(this.props.event.end_date).getMinutes()}`,
            }}
          >
            <label>Resident</label>
            <Control.select model=".resident_id" id="local.resident_id" className="w-75">
              {this.props.residents.map(resident => (
                <option key={resident[0]} value={resident[0]}>{resident[2]} - {resident[1]}</option>
              ))}
            </Control.select>
            <br />

            <label>Day</label>
            <Control type="date" id="local.day" model=".day" className="w-75" />
            <br />

            <label>Start Time</label>
            <Control type="time" id="local.start_time" model=".start_time" className="w-75" />
            <br />

            <label>End Time</label>
            <Control type="time" id="local.end_time" model=".end_time" className="w-75" />
            <br />

            <button type="submit" className="button-dark">Update</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default CommonHouseReservationsEdit;
