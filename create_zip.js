const JSZip = require("jszip");
const fs = require("fs");
const version = require("./package.json").version;

const addonName = "GearOverview";

// Create the folder to put all the zip files in
const zipFolder = "builds";
if (!fs.existsSync(zipFolder)) {
    fs.mkdirSync(zipFolder);
}

// Generate a unique zip filename
let buildCounter = 0;
let zipFilename = `${addonName}-${version}.zip`;
while (fs.existsSync(`${zipFolder}/${zipFilename}`)) {
    buildCounter += 1;
    zipFilename = `${addonName}-${version}-${buildCounter}.zip`;

}

try {
    const zip = new JSZip();

    const files = [
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        `${addonName}.txt`,
    ]

    const addonFolder = zip.folder(addonName);

    for (const filename of files) {
        console.log("Adding", filename);
        addonFolder.file(filename, fs.readFileSync(filename));
    }

    // Add all the files mentioned in the addon base file
    const addonFileContents = fs.readFileSync(`${addonName}.txt`)
    for (const line of String(addonFileContents).split("\n")) {
        const filename = line.trim();
        try {
            addonFolder.file(filename, fs.readFileSync(filename));
            console.log("Adding", filename);
        } catch (e) {

        }
    }

    zip
        .generateNodeStream({type: "nodebuffer", streamFiles: true})
        .pipe(fs.createWriteStream(`${zipFolder}/${zipFilename}`))
        .on("finish", () => {
            console.log(`${zipFolder}/${zipFilename} written`);
        });
} catch (err) {
    console.error(err)
}