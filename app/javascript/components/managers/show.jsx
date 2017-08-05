import React from "react";
import Cookie from "js-cookie";
import axios from "axios";

class ManagersShow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      communities: []
    };
  }

  componentDidMount() {
    // Setup Axios Headers
    axios.interceptors.request.use(
      function(config) {
        const token = Cookie.get("token");

        if (token != null) {
          config.headers.Authorization = `Bearer ${token}`;
          config.headers.Accept = "application/json";
        }

        return config;
      },
      function(err) {
        return Promise.reject(err);
      }
    );

    const self = this;
    axios
      .get(
        `${window.host}api.comeals${window.topLevel}/api/v1/managers/communities`
      )
      .then(function(response) {
        if (response.status === 200) {
          self.setState({ communities: response.data.communities });
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

  logout() {
    Cookie.remove("token", { domain: `.comeals${window.topLevel}` });
    window.location.href = `${window.host}www.comeals${window.topLevel}`;
  }

  createCommunity() {
    window.location.href = "/communities/new";
  }

  communitiesBlock() {
    if (this.state.communities.length > 0) {
      return (
        <div>
          <h3>Communities</h3>
          {this.state.communities.map(community =>
            <a
              href={"/communities/" + community.id}
              key={community.id.toString()}
            >
              <h4>
                {community.name}
              </h4>
            </a>
          )}
        </div>
      );
    } else {
      return <h3>No Communities</h3>;
    }
  }

  render() {
    return (
      <div>
        ManagersShow Component
        <br />
        <button onClick={this.logout}>Logout</button>
        <button onClick={this.createCommunity}>Create a Community</button>
        {this.communitiesBlock()}
      </div>
    );
  }
}

export default ManagersShow;
