import React from 'react'

class CommunitiesShow extends React.Component {
  render() {
    return(<div>
            <h3>Id: {this.props.id}</h3>
            <h3>Name: {this.props.name}</h3>
            <ul>
              <li>Create units / residents</li>
              <li>Create meals</li>
            </ul>
          </div>)
  }
}

export default CommunitiesShow
