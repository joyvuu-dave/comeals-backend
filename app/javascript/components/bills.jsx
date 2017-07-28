import React from 'react'
import { inject, observer } from 'mobx-react'
import { v4 } from 'uuid'

const BillEdit = inject("store")(
  observer(({ store, bill }) =>
    <div>
      <select key={bill.id} value={bill.resident_id} onChange={e => bill.setResident(e.target.value)} >
        <option value={''} key={-1}></option>
        {store.residents.values().map((resident) => <option value={resident.id} key={resident.id}>{resident.name}</option>)}
      </select>
      $<input type="text" value={bill.amount} onChange={e => bill.setAmount(e.target.value)} />
      {!bill.amountIsValid && <span>Error</span>}
      <br />
    </div>
  )
)

const BillShow = inject("store")(
  observer(({ store, bill }) =>
    <ul className={!bill.resident && "is-hidden"}>
      <li key={v4()}>{bill.resident && bill.resident.name}</li>
      <li key={bill.id}>{bill.amount}</li>
    </ul>
  )
)

const Bills = inject("store")(
  observer(({ store }) =>
    <div>
      {store.bills.values().map((bill) => {
        if (store.editMode) {
          return (<BillEdit key={bill.id} bill={bill} />);
        } else {
          return (<BillShow key={bill.id} bill={bill} />);
        }
      })}
    </div>
  )
)

export default Bills
