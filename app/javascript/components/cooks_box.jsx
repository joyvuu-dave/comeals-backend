import React from "react";
import { inject, observer } from "mobx-react";
import { v4 } from "uuid";

const styles = {
  main: {
    gridArea: "a4",
    border: "0.5px solid",
    borderRadius: "var(--button-border-radius)"
  },
  grid: {
    display: "flex",
    flexWrap: "no-wrap"
  }
};

const BillEdit = inject("store")(
  observer(({ store, bill }) =>
    <div className="input-group">
      <select
        key={bill.id}
        value={bill.resident_id}
        onChange={e => bill.setResident(e.target.value)}
      >
        <option value={""} key={-1} />
        {store.residents.values().map(resident =>
          <option value={resident.id} key={resident.id}>
            {resident.name}
          </option>
        )}
      </select>
      <div className="input-group">
        <span className="input-addon">$</span>
        <input
          type="number"
          min="0"
          max="999"
          step="0.01"
          value={bill.amount}
          onChange={e => bill.setAmount(e.target.value)}
          className={bill.amountIsValid ? "" : "input-invalid"}
        />
      </div>
    </div>
  )
);

const BillShow = inject("store")(
  observer(({ store, bill }) =>
    <tr className={!bill.resident && "is-hidden"}>
      <td key={v4()}>
        {bill.resident && bill.resident.name}
      </td>
      <td key={bill.id}>
        ${bill.amount}
      </td>
    </tr>
  )
);

const Display = inject("store")(
  observer(({ store }) =>
    <table>
      <tbody>
        {store.bills
          .values()
          .map(bill => <BillShow key={bill.id} bill={bill} />)}
      </tbody>
    </table>
  )
);

const Edit = inject("store")(
  observer(({ store }) =>
    <div>
      {store.bills.values().map(bill => <BillEdit key={bill.id} bill={bill} />)}
    </div>
  )
);

const CooksBox = inject("store")(
  observer(({ store }) =>
    <div className="offwhite" style={styles.main}>
      <div className="flex space-between title">
        <h2>Cooks</h2>
        <button
          className={store.editBillsMode ? "button-inverse" : "button-danger"}
          onClick={store.toggleEditBillsMode}
        >
          {store.editBillsMode ? "Save" : "Edit"}
        </button>{" "}
      </div>
      {store.editBillsMode ? <Edit /> : <Display />}
    </div>
  )
);

export default CooksBox;
