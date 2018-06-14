import React, { Component } from 'react';
import ReactQuill from 'react-quill';

class TextInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    if (value === undefined) value = props.setting.default || '';

    var html = props.setting || false;

    var rows = props.setting || 10;

    var line_break = props.settings || false;

    this.state = {
      value,
      html,
      rows,
      line_break
    };

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(value) {
    switch(this.state.html) {
      case "true": {
        this.setState({ value }, () => {
          this.props.onChange(this.props.setting.type, this.props.setting.id, value)
        });
        break;
      }
      default: {
        const { value } = value.target;
        this.setState({ value }, () => {
          this.props.onChange(this.props.setting.type, this.props.setting.id, value)
        });
        break;
      }
    }
  }

  render() {
    const { setting } = this.props;
    console.log(this.state.html)
    switch(this.state.html) {

      case "true": {
        return (
          <ReactQuill theme="snow"
                      value={this.state.value}
                      onChange={this.handleChange} />
        )
        break;
      }
      default: {
        return (
          <div className="editor-input editor-input-text">
            <label>{setting.label}</label>
            <br/>
            <input type="text" value={this.state.value} onChange={this.handleChange} />
          </div>
        )
        break;
      }
    }
  }

}

export default TextInput;
