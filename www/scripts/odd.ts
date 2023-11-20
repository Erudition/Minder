import * as odd from '@oddjs/odd'


const appInfo = { creator: "Minder", name: "Minder" }

export function init() : odd.Program | string {
    let problem = "Unforeseen error initializing ODD"

    const program = odd.program({
        namespace: appInfo,
        debug: true, //lets us access window.__odd[odd.namespace(appInfo)]
        fileSystem: { loadImmediately: true }
    
    }).catch(error => {
        switch (error) {
        case odd.ProgramError.InsecureContext:
            // ODD requires HTTPS
            problem = "Insecure context"
            break;
        case odd.ProgramError.UnsupportedBrowser:
            // Browsers must support IndexedDB
            problem = "Unsupported browser"
            break;
        }
    }).then(program => {
        if (program) {
            // happy path
        program.on('session:create', ({ session }) => { 
            console.log('A session was created', session)
        })
        
        program.on('session:destroy', ({ username }) => { 
            console.log('A session was destroyed for username', username)
        })
        
        let session = program.session
        
        if (session) {
            console.log("You have a WNFS session! \n Username:" + session.username + "\n Type: "+ session.type + "\n Filesystem Root DID: " + session.fs?.account.rootDID)
        } else {
            let chosenUsername = prompt("Enter a new username")
            let chosenEmail = prompt("Enter a new email")
            if (chosenUsername && chosenEmail) {
            registerUser(program, chosenUsername, chosenEmail);
            }
        }
          return program;
        }
    })
    return problem;
  
}


export async function linkNewDeviceWithSession(program: odd.Program, session: odd.Session) {
    const producer = await program!.auth.accountProducer(session.username)

    producer.on("challenge", challenge => {
    // Either show `challenge.pin` or have the user input a PIN and see if they're equal.
    if (window.confirm("For security, only choose OK if the PIN matches exactly on the other device.\nPIN: " + challenge.pin)) 
        challenge.confirmPin()
    else challenge.rejectPin()
    })

    producer.on("link", ({ approved }) => {
    if (approved) console.log("Linked new device successfully")
    })

}

export async function linkNewDeviceWithoutSession(program: odd.Program, username: string) {
    const consumer = await program.auth.accountConsumer(username)

    consumer.on("challenge", ({ pin }) => {
        alert("Match this PIN on the other device. \nPIN: " + pin)
    })
    
    consumer.on("link", async ({ approved, username }) => {
        if (approved) {
        console.log(`Successfully authenticated as ${username}`)
        return await program.auth.session()
        }
    })

}

export async function registerUser(program: odd.Program, username: string, email: string) {

	if (!program.session) 
	{
	  // Check if username is valid and available
	  const valid = await program.auth.isUsernameValid(username)
	  const available = await program.auth.isUsernameAvailable(username)

	  if (valid && available) 
	  {
	  // Register the user
	  const { success } = await program.auth.register({ username, email })
	  
	  // Create a session on success
	  const session = success ? await program.auth.session() : null

	  }
	} else 
	{
	  console.error("Tried to registerUser but there was already an existing session.", !program.session)
	}

}

export async function saveData(program: odd.Program, session: odd.Session, ron : string) {
  if (session.fs)
  {
	// After retrieving a session or loading the file system manually
	const fs = session.fs // or program.loadFileSystem(username)

	// List the user's public files
	await fs.ls(odd.path.directory("public"))

	// List the user's private files that belong to a specific app
	await fs.ls(odd.path.appData(appInfo))

	// Create a sub directory and write to a file
	await fs.write(
	  odd.path.appData(appInfo, odd.path.file("RON", "profile.ron")),
	  new TextEncoder().encode(ron)
	)

	// Persist changes and announce them to your other devices
	await fs.publish()
  } else 
  {
	console.error("Tried to saveData but fs was missing. Program is", program, "session is", session, "fs is", session!.fs)
  }
}


export async function readData(program: odd.Program, session: odd.Session) {
  if (session.fs)
  {
	let fileExists = await session.fs.exists( odd.path.appData(appInfo, odd.path.file("RON", "profile.ron")) )
	let content = "";

	if (fileExists) {
	  console.log("minder path exists." )
	  // Read from the file
	  content = new TextDecoder().decode(
		await session.fs.read(
		  odd.path.appData(appInfo, odd.path.file("RON", "profile.ron"))
		)
	  )
	} else {
	  await session?.fs!.write(
		odd.path.appData(appInfo, odd.path.file("RON", "profile.ron")),
		new TextEncoder().encode("start;")
	  )
	}

	return content;
  } else 
  {
	console.error("Tried to readData but fs was missing. Program is", program, "session is", session, "fs is", session!.fs)
	return null;
  }
}