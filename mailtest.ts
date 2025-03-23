const net = require("net");

const smtpServer: string = "localhost";
const smtpPort: number = 25;
const helloMessage: string = "example.com";
const fromEmail: string = "test1@example.com";
const toEmails: Array<string> = ["test1@example.com", "test2@example.com", "test3@example.com"];
const ccEmails: Array<string> = ["cc1@example.com", "cc2@example.com", "cc3@example.com"];
const bccEmails: Array<string> = ["bcc1@example.com", "bcc2@example.com", "bcc3@example.com"];
const subject: string = "Test Mail";
const message: string = "Hello.  This is Test email.";

async function sendEmail() {

  const client = new net.Socket();

  function waitFor(response: string): Promise<void> {
    return new Promise((resolve, reject) => {
      client.once("data", (data: Buffer) => {
        const text: string = data.toString();
        if (text.includes(response)) {
          resolve();
        } else {
          reject(new Error(`Expected response "${response}" not received. Got: ${text}`));
        }
      });
    });
  }

  function sendLine(line: string) {
    client.write(line + "\r\n");
  }

  return new Promise<void>((resolve, reject) => {
    client.connect(smtpPort, smtpServer, async () => {
      try {
        await waitFor("220");
        sendLine(`EHLO ${helloMessage}`);
        await waitFor("250");

        sendLine(`MAIL FROM:<${fromEmail}>`);
        await waitFor("250");

        const allRecipients = toEmails.concat(ccEmails).concat(bccEmails);
        for (const email of allRecipients) {
          sendLine(`RCPT TO:<${email}>`);
          await waitFor("250");
        }

        sendLine("DATA");
        await waitFor("354");

        sendLine(`From: ${fromEmail}`);
        sendLine(`To: ${toEmails.join(", ")}`);
        sendLine(`Cc: ${ccEmails.join(", ")}`);
        sendLine(`Subject: ${subject}`);
        sendLine("");
        sendLine(message.trim());
        sendLine("");
        sendLine(".");
        await waitFor("250");

        sendLine("QUIT");
        await waitFor("221");

        client.end();
        resolve();
      } catch (err) {
        client.end();
        reject(err);
      }
    });

    client.on("error", reject);
  });
}

sendEmail()
  .then(() => console.log("Email sent successfully."))
  .catch((err) => console.error("Error sending email:", err));
