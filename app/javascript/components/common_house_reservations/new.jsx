import React from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";

class CommonHouseReservationsNew extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    axios
      .post(`${window.host}api.comeals${window.topLevel}/api/v1/common-house-reservations?community_id=${window.community_id}`, {
        resident_id: values.resident_id,
        start_year: values.day.split("-")[0],
        start_month: values.day.split("-")[1],
        start_day: values.day.split("-")[2],
        start_hours: values.start_time.split(":")[0],
        start_minutes: values.start_time.split(":")[1],
        end_hours: values.end_time.split(":")[0],
        end_minutes: values.end_time.split(":")[1]
      })
      .then(function(response) {
        if (response.status === 200) {
          window.location.href = `${window.host}patches.comeals${window.topLevel}/calendar`;
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
          <h2 className="mar-md">New Common House Reservation</h2>
        </div>
        <fieldset className="w-50">
          <legend>Edit</legend>
          <LocalForm
            onSubmit={values => this.handleSubmit(values)}
          >
            <label>Resident</label>
            <Control.select model=".resident_id" id="local.resident_id" className="w-75">
              <option></option>
              {this.props.residents.map(resident => (
                <option key={resident[0]} value={resident[0]}>{resident[1]} - Unit {resident[2]}</option>
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

            <button type="submit" className="button-dark">Create</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default CommonHouseReservationsNew;
