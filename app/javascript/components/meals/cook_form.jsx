import React from 'react'
import { LocalForm, Control } from 'react-redux-form'

class CookForm extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    window.alert('Submit Cook Form!')
    // axios.post("http://api.comeals.dev/api/v1/residents/token", {
    //   email: values.email,
    //   password: values.password
    // })
    // .then(function (response) {
    //   if(response.status === 200) {
    //     console.log('data', response.data)
    //     Cookie.set('token', response.data.token, { expires: 7300, domain: '.comeals.dev' })
    //     window.location.href = `http://${response.data.slug}.comeals.dev/calendar`
    //   }
    // })
    // .catch(function (error) {
    //   if (error.response) {
    //     // The request was made and the server responded with a status code
    //     // that falls out of the range of 2xx
    //     const data = error.response.data
    //     const status = error.response.status
    //     const headers = error.response.headers

    //     window.alert(data.message)
    //   } else if (error.request) {
    //     // The request was made but no response was received
    //     // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
    //     // http.ClientRequest in node.js
    //     const request = error.request
    //   } else {
    //     // Something happened in setting up the request that triggered an Error
    //     const message = error.message
    //   }
    //   const config = error.config
    // })
  }

  render() {
    return(
      <div>
        <h3>Cook Form</h3>
        <LocalForm key="cook-form"
          onUpdate={(form) => this.handleUpdate(form)}
          onChange={(values) => this.handleChange(values)}
          onSubmit={(values) => this.handleSubmit(values)}
        >
          <label>Cook 1</label>
          <Control.select model=".cook-1">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
          </Control.select>
          <Control.input model=".cook-1-cost" placeholder="Cost" />
          <br />

          <label>Cook 2</label>
          <Control.select model=".cook-2">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
          </Control.select>
          <Control.input model=".cook-2-cost" placeholder="Cost" />
          <br />

          <label>Cook 3</label>
          <Control.select model=".cook-3">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
          </Control.select>
          <Control.input model=".cook-3-cost" placeholder="Cost" />
          <br />

          <label>Description</label>
          <Control.textarea model=".description" />
          <br />

          <label>Max</label>
          <Control.input model=".max" />
          <br />

          <label>Closed</label>
          <Control.checkbox model=".close" />
          <br />

          <button type="submit">Submit</button>
        </LocalForm>
      </div>
    )
  }
}

export default CookForm
