import { types, getParent } from "mobx-state-tree"
import { v4 } from 'uuid'

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
        amount_cents: 0,
        get resident_id() {
            return (this.resident && this.resident.id) ? this.resident.id : ''
        },
        get amount() {
            if (this.amount_cents === 0) return ''
            else return (this.amount_cents / 100).toFixed(2)
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
            const num = Number(val) * 100

            if (!Number.isInteger(num)) {
                this.amount_cents = 0
                return 0
            }

            if (Number.isInteger(num) && num < 0) {
                this.amount_cents = 0
                return 0
            }

            if (Number.isInteger(num) && num >= 0) {
                this.amount_cents = num
                return num
            }
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





/*
DATA
*/
const data = {
    id: 1,
    description: "Shrimp tacos, spicy salsa",
    max: null,
    closed: false,
    residents: [
        {id: 1, name: 'Barack Obama'},
        {id: 2, name: 'Donald Trump'}
    ],
    bills: [{resident_id: 1, amount_cents: 999}]
}








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
            return (this.meal && this.meal.id) ? this.meal.id : v4()
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
            return this.residentStore.residents.values()
        },
        get bills() {
            return this.billStore.bills.values()
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
        submit() {
            // Format Bills
            let bills = this.bills
                        .map(bill => bill.toJSON())
                        .map((bill) => {
                            let obj = Object.assign({}, bill)
                            obj['resident_id'] = obj['resident']
                            delete obj['id']
                            delete obj['resident']
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

            // TODO: Persist to server
            const response = 200

            // Scenario #1: 200
            if (response === 200) {
                // 1: Reload initial Data
                // 2: Display success message
                window.alert('Form has been saved!')
            }

            // Scenario #2: 400
            if (response === 400) {
                // 1. Reload initial Data
                // 2. Display error message
                window.alert('Error with your form!')
            }

            // Scenario #3: 500
            if (response === 500) {
                window.alert('Form could not be submitted!')
            }
        },
        loadDataAsync() {
            window.setTimeout(this.loadData(data), 1000)
        },
        loadData(data) {
            // Create Meal Object
            const meal = {
                id: data.id,
                description: data.description,
                max: data.max,
                closed: data.closed
            }

           // Assign Meal
            this.meals.push(meal)
            this.meal = meal.id

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
