import React from 'react'
import axios from 'axios'
import AttendeeForm from './components/attendee_form'
import CookForm from './components/cook_form'
import { Provider } from 'mobx-react'
import { types } from 'mobx-state-tree'

const MealModel = types.model("MealModel", {
  id: types.identifier(types.number),
  description: types.maybe(types.string),
  max: types.maybe(types.number),
  closed: types.optional(types.boolean, false)
}, {
  setDescription(val) {
    this.description = val
  },
  setMax(val) {
    this.max = val
  },
  setClosed(val) {
    this.closed = val
  }
})

const ResidentModel = types.model("ResidentModel", {
  id: types.identifier(types.number),
  name: types.string
})

const BillModel = types.model("BillModel", {
  resident_id: types.reference(ResidentModel),
  amount_cents: types.maybe(types.number)
}, {
  setResidentId(val) {
    this.resident_id = val
  },
  setAmountCents(val) {
    this.amount_cents = val
  }
})

const CookFormModel = types.model("CookFormModel", {
  id: types.identifier(types.number),
  description: types.maybe(types.string),
  max: types.maybe(types.number),
  closed: types.boolean,
  residents: types.optional(types.array(ResidentModel), []),
  bills: types.optional(types.array(BillModel), [])
}, {
  setDescription(val) {
    this.description = val
  },
  setMax(val) {
    this.max = val
  },
  setClosed(val) {
    this.closed = val
  }
})


class MealsShow extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      dataDidLoad: false,
      store: null
    }
  }

  componentDidMount() {
    const self = this
    axios.get("http://api.comeals.dev/api/v1/meals/1/cooks")
    .then(function(response) {
      if(response.status === 200) {
        const cookFormStore = CookFormModel.create(response.data)
        self.setState({
          dataDidLoad: true,
          store: cookFormStore
        })
      } else {
        window.alert(`Error: ${response.status}`)
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

  render() {
    return(
      <div>
        {this.state.dataDidLoad ?
          <Provider>
            <CookForm store={this.state.store} />
          </Provider>
          :
          <h1>Loading...</h1>
        }
        <br />
        <AttendeeForm />
      </div>
    )
  }
}

export default MealsShow
