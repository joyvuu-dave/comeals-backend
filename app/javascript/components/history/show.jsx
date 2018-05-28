import React, { Component } from "react";
import axios from "axios";
import Cookie from "js-cookie";
import moment from "moment";

const styles = {
  sticky: {
    position: "sticky",
    top: 0,
    zIndex: "9999"
  }
};

class MealHistoryShow extends Component {
  constructor(props) {
    super(props);

    this.state = {
      items: [],
      ready: false
    };
  }

  componentDidMount() {
    var host = `${window.location.protocol}//`;
    var topLevel = window.location.hostname.split(".")[2];

    var self = this;
    axios
      .get(
        `${host}api.comeals.${topLevel}/api/v1/meals/${
          self.props.id
        }/history?token=${Cookie.get("token")}`
      )
      .then(function(response) {
        if (response.status === 200) {
          self.setState({
            items: response.data,
            ready: true
          });
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
        {this.state.ready && (
          <div>
            <div className="flex center">
              <h1 className="cell">{this.props.date}</h1>
            </div>
            <table className="table-striped background-white">
              <thead>
                <tr>
                  <th style={styles.sticky} className="background-white">
                    ID
                  </th>
                  <th style={styles.sticky} className="background-white">
                    User
                  </th>
                  <th style={styles.sticky} className="background-white">
                    Action
                  </th>
                  <th style={styles.sticky} className="background-white">
                    Time
                  </th>
                </tr>
              </thead>
              <tbody>
                {this.state.items.map(audit => {
                  return (
                    <tr key={audit.id}>
                      <td>{audit.id}</td>
                      <td>{audit.user_name}</td>
                      <td>{audit.description}</td>
                      <td>
                        {moment(audit.display_time).format("ddd MMM D, h:mm a")}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
        {!this.state.ready && <h3>Loading...</h3>}
      </div>
    );
  }
}

export default MealHistoryShow;
