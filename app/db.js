import sql from "mssql";
import { ManagedIdentityCredential, DefaultAzureCredential } from "@azure/identity";
import { execOnce } from "./util.js";

const sqlServerHost = process.env.Quotes__SqlServer;
const database = process.env.Quotes__Database;
if (!sqlServerHost || !database) {
    throw new Error("Missing Quotes__SqlServer or Quotes__Database app settings.");
}

// Acquire an AAD access token for Azure SQL
async function getSqlAccessToken() {
    // App Service has System Assigned MI; ManagedIdentityCredential 
    const cred = new ManagedIdentityCredential();
    const scope = "https://database.windows.net//.default";
    const token = await cred.getToken(scope).catch(async () => {
        const dflt = new DefaultAzureCredential();
        return dflt.getToken(scope);
    });
    return token.token;
}

const poolPromise = execOnce(async () => {
    const token = await getSqlAccessToken();
    const cfg = {
        server: sqlServerHost,
        database,
        options: {
            encrypt: true,
            enableArithAbort: true
        },
        authentication: {
            type: "azure-active-directory-access-token",
            options: { token }
        }
    };
    const pool = new sql.ConnectionPool(cfg);
    await pool.connect();
    return pool;
});

export async function queryOneRandomQuote() {
    const pool = await poolPromise();
    const result = await pool.request()
        .query(`
      SELECT TOP (1) [Id], [Text], [Author]
      FROM dbo.Quotes
      ORDER BY NEWID();
    `);
    return result.recordset[0] || null;
}

export async function ensureSchemaAndSeed() {
    const pool = await poolPromise();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
        const r1 = new sql.Request(tx);
        await r1.batch(`
      IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Quotes') AND type = 'U')
      BEGIN
        CREATE TABLE dbo.Quotes (
          Id INT IDENTITY(1,1) PRIMARY KEY,
          [Text] NVARCHAR(400) NOT NULL,
          [Author] NVARCHAR(200) NULL,
          CreatedAt DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME()
        );
        CREATE INDEX IX_Quotes_CreatedAt ON dbo.Quotes(CreatedAt);
      END;
    `);

        const r2 = new sql.Request(tx);
        const exists = await r2.query(`SELECT TOP 1 1 AS x FROM dbo.Quotes`);
        if (exists.recordset.length === 0) {
            const r3 = new sql.Request(tx);
            r3.input("a1", sql.NVarChar, "Albert Einstein");
            r3.input("q1", sql.NVarChar, "Life is like riding a bicycle. To keep your balance you must keep moving.");
            r3.input("a2", sql.NVarChar, "Oscar Wilde");
            r3.input("q2", sql.NVarChar, "Be yourself; everyone else is already taken.");
            r3.input("a3", sql.NVarChar, "Maya Angelou");
            r3.input("q3", sql.NVarChar, "You will face many defeats in life, but never let yourself be defeated.");
            await r3.batch(`
        INSERT INTO dbo.Quotes([Text],[Author]) VALUES (@q1,@a1),(@q2,@a2),(@q3,@a3);
      `);
        }

        await tx.commit();
    } catch (e) {
        await tx.rollback();
        throw e;
    }
}
