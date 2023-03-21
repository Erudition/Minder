function wrapElmCode(code) {
  return `
    function wrapper() {
      let output = {};
      console.log("About to run Elm Code!");
      (function () { ${code} }).call(output);
      return output.Elm;
    }
    export default wrapper;
  `;
}

module.exports = wrapElmCode;
