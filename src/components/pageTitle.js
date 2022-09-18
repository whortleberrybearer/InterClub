import * as React from "react"
import PropTypes from "prop-types"
import { Container } from "react-bootstrap"

const PageTitle = ({ title, breadcrumbs }) => {
  return (
    <div class="section bg-white">
      <Container>
        <h1 class="fw-bold">
          {title}
        </h1>
        <nav aria-label="breadcrumb">
          <ol class="breadcrumb breadcrumb-sublime small">
            <li class="breadcrumb-item"><a href="#">Home</a></li>
            <li class="breadcrumb-item"><a href="#">Library</a></li>
            <li class="breadcrumb-item active" aria-current="page">Data</li>
          </ol>
        </nav>
      </Container>
    </div>
  )
}

PageTitle.propTypes = {
  title: PropTypes.node.isRequired,
}
  
export default PageTitle