import axios from "axios";

function main() {
  const elm = document.getElementById("content");
  axios
    .get(process.env.API_URL)
    .then((x) => (elm.innerHTML = x.data["CreatedAt"]));
}

main();
