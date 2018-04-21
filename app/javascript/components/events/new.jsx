import React from "react";
import { LocalForm, Control, actions } from "react-redux-form";
import DayPickerInput from 'react-day-picker/DayPickerInput';
import { formatDate, parseDate } from 'react-day-picker/moment';
import moment from "moment";
import axios from "axios";
import { generateTimes } from "../../helpers/helpers"

class EventsNew extends React.Component {
  constructor(props) {
    super(props);
    this.handleDayChange = this.handleDayChange.bind(this);
  }

  handleSubmit(values) {
    if(values.start_time > values.end_time) {
      window.alert('Start time cannot be later than end time')
      return
    }

    axios
      .post(`${window.host}api.comeals${window.topLevel}/api/v1/events?community_id=${window.community_id}`, {
        title: values.title,
        description: values.description,
        start_year: values.day && values.day.split("-")[0],
        start_month: values.day && values.day.split("-")[1],
        start_day: values.day && values.day.split("-")[2],
        start_hours: values.start_time && values.start_time.split(":")[0],
        start_minutes: values.start_time && values.start_time.split(":")[1],
        end_hours: values.end_time && values.end_time.split(":")[0],
        end_minutes: values.end_time && values.end_time.split(":")[1],
        all_day: values.all_day
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

  handleDayChange(val) {
    this.formDispatch(actions.change('local.day', val));
  }

  getDayPickerInput() {
    return (
      <DayPickerInput
        formatDate={formatDate}
        parseDate={parseDate}
        placeholder={""}
        onDayChange={this.handleDayChange} />
    );
  }

  attachDispatch(dispatch) {
    this.formDispatch = dispatch;
  }

  render() {
    return (
      <div>
        <div className="flex">
          <h2 className="mar-md">New Event</h2>
        </div>
        <fieldset className="w-50">
          <legend>Edit</legend>
          <LocalForm
            onSubmit={values => this.handleSubmit(values)}
            getDispatch={(dispatch) => this.attachDispatch(dispatch)}
          >
            <label>Title</label>
            <Control.text model=".title" className="w-75" />
            <br />

            <label>Description</label>
            <Control.textarea model=".description" className="w-75" placeholder="optional" />
            <br />

            <label>Day</label>
            <br />
            <Control.text model="local.day" id="local.day" component={this.getDayPickerInput.bind(this)} />
            <br />
            <br />

            <label>Start Time</label>
            <Control.select model="local.start_time" id="local.start_time" className="w-50">
              <option></option>
              {generateTimes().map(time => (
                <option key={time.value} value={time.value}>{time.display}</option>
              ))}
            </Control.select>
            <br />

            <label>End Time</label>
            <Control.select model="local.end_time" id="local.end_time" className="w-50">
              <option></option>
              {generateTimes().map(time => (
                <option key={time.value} value={time.value}>{time.display}</option>
              ))}
            </Control.select>
            <br />

            <label>All Day</label>{' '}
            <Control.input type="checkbox" model="local.all_day" className="w-75" />
            <br />
            <br />

            <button type="submit" className="button-dark">Create</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default EventsNew;
