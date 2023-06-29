// 构建和部署
const configLocal = require('../config.local')
const childProcess = require('child_process')

let msg = ''

msg = childProcess.execSync(`yarn build`)

console.log(msg.toString())
console.log('编译成功')

childProcess.execSync(`cp -r ./funnymap ${configLocal.deployPath}/funnymap`)

console.log('部署成功')
