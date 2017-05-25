/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Static Pages
import StaticIndex from 'components/static/index'

// Manager Pages
import SignUp from 'components/managers/sign_up'
import Login from 'components/managers/login'
import ManagersShow from 'components/managers/show'

// Community Pages
import CommunitiesNew from 'components/communities/new'
import CommunitiesShow from 'components/communities/show'

import WebpackerReact from 'webpacker-react'
WebpackerReact.setup({StaticIndex,
                      SignUp,
                      Login,
                      ManagersShow,
                      CommunitiesNew,
                      CommunitiesShow})
