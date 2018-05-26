import React, { Component } from "react";
import axios from "axios";
import Cookie from "js-cookie";

const styles = {
  main: {
    backgroundColor: "#ebebe4"
  }
};

class RotationsShow extends Component {
  constructor(props) {
    super(props);

    var topLevel = window.location.hostname.split(".");
    topLevel = topLevel[topLevel.length - 1];

    this.state = {
      host: `${window.location.protocol}//`,
      topLevel: `.${topLevel}`,
      rotation: {
        id: null,
        description: "",
        residents: []
      },
      ready: false
    };
  }

  componentDidMount() {
    var self = this;
    axios
      .get(
        `${self.state.host}api.comeals${self.state.topLevel}/api/v1/rotations/${
          self.props.id
        }?token=${Cookie.get("token")}`
      )
      .then(function(response) {
        if (response.status === 200) {
          self.setState({
            rotation: response.data,
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
      <div style={styles.main}>
        {this.state.ready && (
          <div>
            <div className="flex center">
              <u className="cell">
                <h1>{`Rotation ${this.props.id}`}</h1>
              </u>
            </div>
            <br />
            <div className="flex center">
              <h2 className="cell nine text-success">
                {this.state.rotation.description}
              </h2>
            </div>
            <br />

            <ul>
              {this.state.rotation.residents
                .sort((a, b) => {
                  if (a.display_name < b.display_name) return -1;
                  if (a.display_name > b.display_name) return 1;
                  return 0;
                })
                .map(resident => {
                  return (
                    <div key={resident.id}>
                      {resident.signed_up && (
                        <s>
                          <li className="text-muted">
                            {resident.display_name}
                          </li>
                        </s>
                      )}
                      {!resident.signed_up && (
                        <li className="text-bold text-italic">
                          {resident.display_name}
                        </li>
                      )}
                    </div>
                  );
                })}
            </ul>
          </div>
        )}{" "}
        {!this.state.ready && <h3>Loading...</h3>}
      </div>
    );
  }
}

export default RotationsShow;
