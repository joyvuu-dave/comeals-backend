import React from "react";
import { LocalForm, Control, actions } from "react-redux-form";
import DayPickerInput from 'react-day-picker/DayPickerInput';
import { formatDate, parseDate } from 'react-day-picker/moment';
import moment from "moment";
import axios from "axios";

class CommonHouseReservationsEdit extends React.Component {
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
      .patch(`${window.host}api.comeals${window.topLevel}/api/v1/common-house-reservations/${this.props.event.id}/update`, {
        resident_id: values.resident_id,
        start_year: values.day && new Date(values.day).getFullYear(),
        start_month: values.day && new Date(values.day).getMonth() + 1,
        start_day: values.day && new Date(values.day).getDate(),
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

  handleDayChange(val) {
    this.formDispatch(actions.change('local.day', val));
  }

  getDayPickerInput() {
    return (
      <DayPickerInput
        formatDate={formatDate}
        parseDate={parseDate}
        onDayChange={this.handleDayChange}
        value={formatDate(this.props.event.start_date)}
        />
    );
  }

  attachDispatch(dispatch) {
    this.formDispatch = dispatch;
  }

  generateTimes() {
    var times = [];
    var ending = "AM";

    for(var half = 0; half < 2; half++) {
      for(var hour = 0; hour < 12; hour++) {
        for(var min = 0; min < 4; min++) {
          var time = {
            display: null,
            value: null
          };

          var valueHour = hour;

          if(half === 1) {
            ending = "PM";
            valueHour += 12;
          }

          var minutes = `${(min * 15).toString().padStart(2, "0")}`;

          if(hour === 0) {
            time.display = `12:${minutes} ${ending}`;
          } else {
            time.display = `${hour}:${minutes} ${ending}`;
          }

          time.value = `${(valueHour).toString().padStart(2, "0")}:${minutes}`;

          times.push(time);
        }
      }
    }

    return times;
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
            getDispatch={(dispatch) => this.attachDispatch(dispatch)}
            initialState={{
              resident_id: this.props.event.resident_id,
              day: this.props.event.start_date,
              start_time: `${(new Date(this.props.event.start_date).getHours()).toString().padStart(2, "0")}:${(new Date(this.props.event.start_date).getMinutes()).toString().padStart(2, "0")}`,
              end_time: `${(new Date(this.props.event.end_date).getHours()).toString().padStart(2, "0")}:${(new Date(this.props.event.end_date).getMinutes()).toString().padStart(2, "0")}`
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
            <br />
            <Control.text model="local.day" id="local.day" component={this.getDayPickerInput.bind(this)} />
            <br />
            <br />

            <label>Start Time</label>
            <Control.select model="local.start_time" id="local.start_time" className="w-50">
              <option></option>
              {this.generateTimes().map(time => (
                <option key={time.value} value={time.value}>{time.display}</option>
              ))}
            </Control.select>
            <br />

            <label>End Time</label>
            <Control.select model="local.end_time" id="local.resident_id" className="w-50">
              <option></option>
              {this.generateTimes().map(time => (
                <option key={time.value} value={time.value}>{time.display}</option>
              ))}
            </Control.select>
            <br />

            <button type="submit" className="button-dark">Update</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default CommonHouseReservationsEdit;
