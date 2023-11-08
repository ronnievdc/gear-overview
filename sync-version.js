const fs = require("fs");
const version = process.env['npm_package_version'];

const addonName = "GearOverview";
let data = '';

data = fs.readFileSync(`${addonName}.txt`);
data = data.toString().replace(/## Version: (\d+\.\d+\.\d+)/, `## Version: ${version}`);
fs.writeFileSync(`${addonName}.txt`, data);

data = fs.readFileSync(`${addonName}.lua`);
data = data.toString().replace(/lib.version = "(\d+\.\d+\.\d+)"/, `lib.version = "${version}"`);
fs.writeFileSync(`${addonName}.lua`, data);
