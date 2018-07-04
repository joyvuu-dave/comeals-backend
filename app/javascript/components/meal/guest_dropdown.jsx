import React, { Component } from "react";
import Cow from "../../images/cow.png";
import Carrot from "../../images/carrot.png";
import onClickOutside from "react-onclickoutside";

const styles = {
  topButton: {
    marginBottom: "1px"
  }
};

class GuestDropdown extends Component {
  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);

    this.state = {
      open: false
    };
  }

  handleClickOutside = evt => {
    this.setState({ open: false });
  };

  handleClick(e) {
    this.setState((prevState, props) => {
      return { open: !prevState.open };
    });
  }

  render() {
    return (
      <div
        className={this.state.open ? "dropdown active" : "dropdown"}
        onClick={this.handleClick}
      >
        <button
          key={`dropdown_${this.props.resident.id}`}
          className="dropdown-trigger mar-r-sm"
          style={styles.topButton}
          disabled={this.props.reconciled || !this.props.canAdd}
        >
          + Guest
        </button>
        <div className="dropdown-menu">
          <a onClick={e => this.props.resident.addGuest({ vegetarian: false })}>
            <img src={Cow} className="pointer" alt="cow-icon" />
          </a>
          <a onClick={e => this.props.resident.addGuest({ vegetarian: true })}>
            <img src={Carrot} className="pointer" alt="carrot-icon" />
          </a>
        </div>
      </div>
    );
  }
}

export default onClickOutside(GuestDropdown);
