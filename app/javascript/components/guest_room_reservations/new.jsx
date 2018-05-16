import React, { Component } from "react";
import { LocalForm, Control, actions } from "react-redux-form";
import DayPickerInput from "react-day-picker/DayPickerInput";
import { formatDate, parseDate } from "react-day-picker/moment";
import moment from "moment";
import axios from "axios";
import Cookie from "js-cookie";

class GuestRoomReservationsNew extends Component {
  constructor(props) {
    super(props);
    this.handleDayChange = this.handleDayChange.bind(this);

    var topLevel = window.location.hostname.split(".");
    topLevel = topLevel[topLevel.length - 1];

    this.state = {
      host: `${window.location.protocol}//`,
      topLevel: `.${topLevel}`,
      slug: window.location.hostname.split(".")[0],
      communityId: Cookie.get("community_id")
    };
  }

  handleSubmit(values) {
    var myState = this.state;

    axios
      .post(
        `${myState.host}api.comeals${
          myState.topLevel
        }/api/v1/guest-room-reservations?community_id=${myState.communityId}`,
        {
          resident_id: values.resident_id,
          date: values.day
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          window.location.href = `${myState.host}${myState.slug}.comeals${
            myState.topLevel
          }/calendar/all`;
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

  handleDayChange(val) {
    this.formDispatch(actions.change("local.day", val));
  }

  getDayPickerInput() {
    return (
      <DayPickerInput
        formatDate={formatDate}
        parseDate={parseDate}
        placeholder={""}
        onDayChange={this.handleDayChange}
      />
    );
  }

  attachDispatch(dispatch) {
    this.formDispatch = dispatch;
  }

  render() {
    return (
      <div>
        <div className="flex">
          <h2 className="mar-md">Guest Room Reservation</h2>
        </div>
        <fieldset className="w-50">
          <legend>Edit</legend>
          <LocalForm
            onSubmit={values => this.handleSubmit(values)}
            getDispatch={dispatch => this.attachDispatch(dispatch)}
          >
            <label>Host</label>
            <Control.select
              model="local.resident_id"
              id="local.resident_id"
              className="w-75"
            >
              <option />
              {this.props.hosts.map(host => (
                <option key={host[0]} value={host[0]}>
                  {host[2]} - {host[1]}
                </option>
              ))}
            </Control.select>
            <br />

            <label>Day</label>
            <br />
            <Control.text
              model="local.day"
              id="local.day"
              component={this.getDayPickerInput.bind(this)}
            />
            <br />
            <br />

            <button type="submit" className="button-dark">
              Create
            </button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default GuestRoomReservationsNew;
