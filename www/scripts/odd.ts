import * as odd from '@oddjs/odd'


const program = await odd.program({
  namespace: { creator: "Minder", name: "Minder" },
  debug: false,
  fileSystem: { loadImmediately: true }

}).catch(error => {
  switch (error) {
    case odd.ProgramError.InsecureContext:
      // ODD requires HTTPS
      break;
    case odd.ProgramError.UnsupportedBrowser:
      // Browsers must support IndexedDB
      break;
  }
})


let session

// Do we have an existing session?
if (program.session) {
  session = program.session

// If not, let's authenticate.
// (a) new user, register a new Fission account
} else if (userChoseToRegister) {
  const { success } = await program.auth.register({ username: "llama" })
  session = success ? program.auth.session() : null

// (b) existing user, link a new device
} else {
  // On device with existing session:
  const producer = await program.auth.accountProducer(program.session.username)

  producer.on("challenge", challenge => {
    // Either show `challenge.pin` or have the user input a PIN and see if they're equal.
    if (userInput === challenge.pin) challenge.confirmPin()
    else challenge.rejectPin()
  })

  producer.on("link", ({ approved }) => {
    if (approved) console.log("Link device successfully")
  })

  // On device without session:
  //     Somehow you'll need to get ahold of the username.
  //     Few ideas: URL query param, QR code, manual input.
  const consumer = await program.auth.accountConsumer(username)

  consumer.on("challenge", ({ pin }) => {
    showPinOnUI(pin)
  })

  consumer.on("link", async ({ approved, username }) => {
    if (approved) {
      console.log(`Successfully authenticated as ${username}`)
      session = await program.auth.session()
    }
  })
}




async function registerUser(userName: string, email: string) {
    if (typeof program === odd.program)
    {}
    // Check if username is valid and available
    const valid = program.auth.isUsernameValid(userName)
    const available = await program.auth.isUsernameAvailable(userName)

    if (valid && available) {
    // Register the user
    const { success } = await program.auth.register({ userName })
    
    // Create a session on success
    const session = success ? program.auth.session() : null
    }
}