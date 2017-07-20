import React from 'react'
import { inject, observer } from 'mobx-react'

const Bill = inject("store")(
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

const Bills = inject("store")(
  observer(({ store }) =>
    <div>
      {store.bills.values().map(bill => <Bill key={bill.id} bill={bill} />)}
      <br />
      <button onClick={e => store.submit()}>Update Meal</button>
    </div>
  )
)

export default Bills
