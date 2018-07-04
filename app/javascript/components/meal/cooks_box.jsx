import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    gridArea: "a4",
    border: "0.5px solid"
  },
  grid: {
    display: "flex",
    flexWrap: "no-wrap"
  },
  select: {
    marginLeft: "1px"
  }
};

const BillEdit = inject("store")(
  observer(({ store, bill }) => (
    <div className="input-group">
      <select
        key={bill.id}
        value={bill.resident_id}
        onChange={e => bill.setResident(e.target.value)}
        style={styles.select}
      >
        <option value={""} key={-1}>
          ¯\_(ツ)_/¯
        </option>
        {Array.from(store.residents.values())
          .filter(resident => resident.can_cook === true)
          .map(resident => (
            <option value={resident.id} key={resident.id}>
              {resident.name}
            </option>
          ))}
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
  ))
);

const BillShow = inject("store")(
  observer(({ store, bill }) => (
    <tr key={bill.id} hidden={!bill.resident}>
      <td>{bill.resident && bill.resident.name}</td>
      <td>${bill.amount}</td>
    </tr>
  ))
);

const Display = inject("store")(
  observer(({ store }) => (
    <table>
      <tbody>
        {Array.from(store.bills.values()).map(bill => (
          <BillShow key={bill.id} bill={bill} />
        ))}
      </tbody>
    </table>
  ))
);

const Edit = inject("store")(
  observer(({ store }) => (
    <div>
      {Array.from(store.bills.values()).map(bill => (
        <BillEdit key={bill.id} bill={bill} />
      ))}
    </div>
  ))
);

const CooksBox = inject("store")(
  observer(({ store }) => (
    <div className="offwhite button-border-radius" style={styles.main}>
      <div className="flex space-between title">
        <h2>Cooks</h2>
      </div>
      {store.editBillsMode ? <Edit /> : <Display />}
    </div>
  ))
);

export default CooksBox;
