import { types } from 'mobx-state-tree'
import axios from 'axios'
import { v4 } from 'node-uuid'

/*
MODELS
*/

// Resident
const ResidentModel = types.model("ResidentModel", {
  id: types.identifier(types.number),
  name: types.string,
  get currentId() {
    return this.id
  },
  get currentName() {
    return this.name
  }
})

// Bill
const BillModel = types.model("BillModel", {
  id: types.identifier(types.string),
  resident_id: types.reference(ResidentModel),
  amount_cents: types.maybe(types.number),
  get currentId() {
    return this.id
  },
  get currentResidentId() {
    return this.resident_id
  },
  get currentAmountCents() {
    return this.amount_cents
  }
}, {
  setResidentId(val) {
    this.resident_id = val
  },
  setAmountCents(val) {
    this.amount_cents = val
  }
})

// MealModel
const MealModel = types.model("MealModel", {
  id: types.identifier(types.number),
  description: types.optional(types.string, ""),
  max: types.maybe(types.number),
  closed: types.optional(types.boolean, false),
  residents: types.optional(types.array(ResidentModel), []),
  bills: types.optional(types.array(BillModel), []),
  get currentId() {
    return this.id
  },
  get currentDescription() {
    return this.description
  },
  get currentMax() {
    return this.max ? this.max + "" : ""
  },
  get maxIsValid() {
    return Number.isInteger(this.max)
  },
  get currentClosed() {
    return this.closed
  },
  get currentResidents() {
    return this.residents
  },
  get currentBills() {
    return this.bills
  }
}, {
  setDescription(val) {
    this.description = val
  },
  setMax(val) {
    const number = Number(val)
    if(number < 1) {
      this.max = null
    } else {
      this.max = number
    }
  },
  setClosed(val) {
    this.closed = val
  },
  updateBillAmount(index, amountCents) {
    this.bills[index].setAmountCents(amountCents)
  },
  updateBillResident(index, residentId) {
    this.bills[index].setResidentId(residentId)
  }
})



/*
STORE
*/
const Store = types.model("Store", {
    id: types.identifier(types.string),
    meal: types.maybe(MealModel),
    loaded: false,
    get currentId() {
      return this.id
    },
    get currentMeal() {
      return this.meal
    },
    get currentLoaded() {
      return this.loaded
    }
}, {
    setMeal(val) {
      this.meal = val
   },
    setLoaded(val) {
      this.loaded = val
   },
    fetchData() {
      const self = this
      axios.get("http://api.comeals.dev/api/v1/meals/1/cooks")
      .then(function(response) {
        if(response.status === 200) {
          self.setMeal(response.data)
          self.setLoaded(true)
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
})

export default Store
