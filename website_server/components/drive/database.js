//Dependencies
const Sequelize = require('sequelize');
class DriveDatabase {
    //Contains the connection with database
    database_connection;
    //Contains the users database
    accounts;

    constructor() {
        ///Creates the connection with database
        this.database_connection = new Sequelize('leans_drive', "admin", "SIt65MtHNLS5yZL2Ss5BBsu7HQGZag4kQqebxXIEBaIJvKH6S9", {
            host: "dogaogames.duckdns.org",
            dialect: "mariadb",
            logging: false,
            connectTimeout: 10000,
        });
        ///With connection instanciate the table
        this.accounts = database_connection.define('accounts', {
            id: {
                type: Sequelize.INTEGER,
                autoIncrement: true,
                allowNull: false,
                primaryKey: true
            },
            username: {
                type: "varchar(50)",
                allowNull: false,
                unique: true
            },
            password: {
                type: "varchar(500)",
                allowNull: false,
            },
            token: {
                type: "longtext",
                allowNull: true,
                defaultValue: null
            }
        }, {
            //Disable defaults from sequelize
            timestamps: false,
            createdAt: false,
            updatedAt: false,
        });
        ///Creates the table if not exist
        this.accounts.sync();
    }

    //update the user token based in username
    updateUserToken(token, username) {
        return new Promise(async (resolve, _) => {
            //Get the user key
            let user = await this.database_connection.findOne({
                attributes: ['token'],
                where: {
                    username: username,
                }
            });
            //Change the token section to null
            user.token = token;
            //Confirm changes
            user.save();

            //Finish
            console.log(username + " token updated");
            resolve();
        });
    }

    //invalidate the user token based in username
    invalidateUserToken(username) {
        return new Promise(async (resolve, _) => {
            //Get the user key
            let user = await this.database_connection.findOne({
                attributes: ['token'],
                where: {
                    username: username,
                }
            });
            //Change the token section to null
            user.token = null;
            //Confirm changes
            user.save();

            //Finish
            console.log(username + " token updated");
            resolve();
        });
    }
}
module.exports = new DriveDatabase;