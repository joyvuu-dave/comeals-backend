import React from 'react'
import axios from 'axios'
import Bill from './bill'
import Meal from './meal'

class CookForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      id: -1,
      description: 'pasta and water',
      max: 100,
      closed: true,
      residents: [],
      bills: []
    }
  }

  componentDidMount() {
    const self = this
    axios.get("http://api.comeals.dev/api/v1/meals/1/cooks")
    .then(function(response) {
      if(response.status === 200) {
        self.setState({
          id: response.data.id,
          description: response.data.description,
          max: response.data.max,
          closed: response.data.closed,
          residents: response.data.residents,
          bills: response.data.bills
        })
      }
    })
    .catch(function (error) {
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        const data = error.response.data
        const status = error.response.status
        const headers = error.response.headers

        window.alert(data.message)
      } else if (error.request) {
        // The request was made but no response was received
        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
        // http.ClientRequest in node.js
        const request = error.request
      } else {
        // Something happened in setting up the request that triggered an Error
        const message = error.message
      }
      const config = error.config
    })
  }


  renderRealBills() {
    const self = this
    return (
      <div>
        {self.state.bills.map((bill, index) => <Bill
          key={index}
          index={index}
          resident_id={bill.resident_id}
          amount_cents={bill.amount_cents}
          residents={self.state.residents} /> )}
      </div>
    )
  }

  renderDummyBills() {
    const self = this
    const dummyCount = Math.max(3 - this.state.bills.length, 0)

    return (
      <div>
        {Array.from(Array(dummyCount)).map((val, index) => <Bill
          key={index + self.state.bills.length}
          index={index + self.state.bills.length}
          residents={self.state.residents} /> )}
      </div>
    )
  }


  render() {
    return(
      <div>
        <h3>Cook Form</h3>
        <form>
          {this.renderRealBills()}
          {this.renderDummyBills()}
          <Meal
            description={this.state.description}
            max={this.state.max}
            closed={this.state.closed}
          />
        </form>
      </div>
    )
  }
}

export default CookForm
