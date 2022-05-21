const fs = require("fs");
const version = require("./package.json").version;

const addonName = "GearOverview";
let data = '';

data = fs.readFileSync(`${addonName}.txt`);
console.log(data, data.toString())
data = data.toString().replace(/## Version: (\d+\.\d+\.\d+)/, `## Version: ${version}`);
console.log(data)
fs.writeFileSync(`${addonName}.txt`, data);

data = fs.readFileSync(`${addonName}.lua`);
data = data.toString().replace(/lib.version = "(\d+\.\d+\.\d+)"/, `lib.version = "${version}"`);
fs.writeFileSync(`${addonName}.lua`, data);

