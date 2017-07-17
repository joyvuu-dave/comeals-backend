import { types, getParent } from "mobx-state-tree"
import { v4 } from 'uuid'
import axios from 'axios'
import Cookie from 'js-cookie'

const Meal = types.model(
    "Meal",
    {
        id: types.identifier(types.number),
        description: '',
        max: types.maybe(types.number),
        closed: false,
        get form() {
            return getParent(this)
        }
    }
)


const Resident = types.model("Resident", {
    id: types.identifier(types.number),
    name: types.string
})


const ResidentStore = types.model(
    "ResidentStore",
    {
        residents: types.map(Resident),
        get form() {
            return getParent(this)
        }
    }
)


const Bill = types.model(
    "Bill",
    {
        id: types.identifier(),
        resident: types.maybe(types.reference(Resident)),
        amount: '',
        get resident_id() {
            return (this.resident && this.resident.id) ? this.resident.id : ''
        },
        get amountCents() {
            return Number.parseInt(Number(this.amount) * 100)
        },
        get amountIsValid() {
            return Number.isInteger(this.amountCents) && this.amountCents >= 0
        }
    },
    {
        setResident(val) {
            if (val === '') {
                this.resident = null
                return null
            } else {
                this.resident = val
                return this.resident
            }
        },
        setAmount(val) {
            this.amount = val
            return val
        }
    }
)


const BillStore = types.model(
    "BillStore",
    {
        bills: types.map(Bill),
        get form() {
            return getParent(this)
        }
    }
)




export const FormStore = types.model(
    "FormStore",
    {
        isLoading: true,
        meal: types.maybe(types.reference(Meal)),
        meals: types.optional(types.array(Meal), []),
        residentStore: types.optional(ResidentStore, {
            residents: {}
        }),
        billStore: types.optional(BillStore, {
            bills: {}
        }),
        get id() {
            return this.meal.id
        },
        get description() {
            return (this.meal && this.meal.description) ? this.meal.description : ''
        },
        get max() {
            return (this.meal && this.meal.max) ? this.meal.max : ''
        },
        get closed() {
            return (this.meal && this.meal.closed) ? this.meal.closed : false
        },
        get residents() {
            return this.residentStore.residents
        },
        get bills() {
            return this.billStore.bills
        }
    },
    {
        setDescription(val) {
            this.meal.description = val
            return this.meal.description
        },
        setMax(val) {
            // Scenario #1: empty
            if(val === '') {
                this.meal.max = null
                return ''
            }

            const num = Number(val)

            // Scenario #2: non-integer
            if (!Number.isInteger(num)) {
                this.meal.max = null
                return null
            }

            // Scenario #3: Zero or Negative
            if (Number.isInteger(num) && num < 1) {
                this.meal.max = null
                return null
            }

            // Scenario #4: Greater than 999
            if (Number.isInteger(num) && num > 999) {
                this.meal.max = 999
                return 999
            }

            // Scenario #5: Between 1 and 999
            if (Number.isInteger(num) && num > 0 && num < 1000) {
                this.meal.max = num
                return num
            }
        },
        setClosed(val) {
            this.meal.closed = val
        },
        logout() {
            Cookie.remove('token', { domain: '.comeals.dev' })
            window.location.href = '/'
        },
        submit() {
            // Check for errors
            if (this.bills.values().some((bill) => bill.amountIsValid === false)) {
                window.alert('Fix errors before submitting.')
                return
            }

            // Format Bills
            let bills = this.bills.values()
                        .map(bill => bill.toJSON())
                        .map((bill) => {
                            let obj = Object.assign({}, bill)

                            // delete id
                            delete obj['id']

                            // resident --> resident_id
                            obj['resident_id'] = obj['resident']
                            delete obj['resident']

                            // amount --> amount_cents
                            obj['amount_cents'] = Number.parseInt(Number(obj['amount']) * 100)
                            delete obj['amount']

                            return obj
                        })
                        .filter(bill => bill.resident_id !== null)

            let obj = {
                id: this.meal.id,
                description: this.meal.description,
                max: this.meal.max,
                closed: this.meal.closed,
                bills: bills
            }

            console.log(obj)

            const self = this
            axios.patch(`http://api.comeals.dev/api/v1/meals/${self.meal.id}`, obj)
                 .then(function(response) {
                    if (response.status === 200) {
                        console.log(response.data)
                        window.alert('Meal has been updated!')
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
                    window.alert('Error: no response received from server.')
                  } else {
                    // Something happened in setting up the request that triggered an Error
                    const message = error.message
                    window.alert('Error: could not submit form.')
                  }
                  const config = error.config
                })
        },
        loadDataAsync() {
            const self = this
            axios.get(`http://api.comeals.dev/api/v1/meals/${self.meal.id}/cooks`)
                 .then(function(response) {
                    if (response.status === 200) {
                        window.data = response.data
                        self.loadData(response.data)
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
        },
        loadData(data) {
           // Assign Meal Data
            this.meal.description = data.description
            this.meal.max = data.max
            this.meal.closed = data.closed

            // Assign Residents
            data.residents.forEach(resident => {
                this.residentStore.residents.put(resident)
            })

            // Assign Bills
            let bills = data.bills

            // Rename resident_id --> resident
            bills = bills.map((bill) => {
                bill['resident'] = bill['resident_id']
                delete bill['resident_id']
                return bill
            })

            // Convert amount_cents --> amount
            bills = bills.map((bill) => {
                bill['amount'] = bill['amount_cents'] === 0 ? '' : (bill['amount_cents'] / 100).toFixed(2)
                delete bill['amount_cents']
                return bill
            })

            // Determine # of blank bills needed
            const extra = Math.max(3 - bills.length, 0)

            // Create array for iterating
            const array = Array(extra).fill()

            // Create blanks bills
            array.forEach(() => bills.push([]))

            // Assign ids to bills
            bills = bills.map(obj => Object.assign({ id: v4() }, obj))

            // Put bills into BillStore
            bills.forEach(bill => {
                this.billStore.bills.put(bill)
            })

            // Change loading state
            this.isLoading = false
        },
        afterCreate() {
            this.loadDataAsync()
        }
    }
)
