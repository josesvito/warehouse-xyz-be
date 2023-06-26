'use strict';

const response = require('./res');
const connection = require('./conn');
const handle = require('./utils');
const bcrypt = require('bcryptjs');
const moment = require('moment');

const login = (user) => {
  const query = "UPDATE user SET last_login=?, token=? WHERE id=?"
  connection.query(query, [new Date(), user.token, user.id])
}

exports.login = (req, res) => {
  const query = "SELECT u.*, r.name AS role FROM user u JOIN master_role r ON r.id = u.master_role_id " +
    "WHERE username = ? LIMIT 1"
  connection.query(query, [req.body.username, req.body.password], (error, rows, fields) => {
    if (error) {
      response.fail(error, res)
    } else {
      if (bcrypt.compareSync(req.body.password, rows[0].password)) {
        const user = {
          id: rows[0].id,
          username: rows[0].username,
          name: rows[0].name,
          id_npwp: rows[0].id_npwp,
          role: rows[0].role,
          role_id: rows[0].master_role_id,
          is_active: rows[0].is_active,
        }
        user.token = user.is_active ? handle.jwtSign(user) : null
        login(user)
        if(user.token) response.ok(user, res)
        else response.fail('Account has been deactivated', res)
      } else response.fail('Wrong username/password', res)
    }
  })
}

exports.logout = (req, res) => {
  const query = "UPDATE user SET token=null WHERE token=?"
  connection.query(query, [req.headers.token], (error, rows, fields) => {
    if (error) response.fail(error, res)
    else if (rows.affectedRows > 0) response.ok("Logout Successful", res)
    else response.fail("Something went wrong", res)
  })
}

exports.getDashboardChart = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "SELECT event_date, SUM(quantity_in) AS quantity_in, SUM(quantity_returned) AS quantity_returned, SUM(quantity_out) AS quantity_out, SUM(quantity_exp) AS quantity_exp FROM (SELECT p.date_procured AS event_date, SUM(p.quantity) AS quantity_in, SUM(r.quantity) AS quantity_returned, NULL AS quantity_out, SUM(IF(p.date_exp <= now(), p.quantity - IFNULL(p.quantity_out, 0), 0)) AS quantity_exp FROM procurement p LEFT JOIN returned r ON r.procurement_id = p.id WHERE p.date_procured >= date_sub(now(), interval 1 month) GROUP BY p.date_procured UNION SELECT pu.date_purchase, NULL, NULL, SUM(pu.quantity), NULL FROM purchase pu WHERE pu.date_purchase >= date_sub(now(), interval 1 month) GROUP BY pu.date_purchase) AS chart GROUP BY event_date ORDER BY event_date ASC";
    connection.query(query, (error, rows, fields) => {
      if (error) response.fail(error, res)
      else {
        const template = (date) => ({
          event_date: date,
          quantity_in: 0,
          quantity_returned: 0,
          quantity_out: 0,
          quantity_exp: 0
        })
        rows.map(el => {
          el.event_date = moment(String(el.event_date)).format("DD-MM-YY").toString()
          for (const i in el) 
            if (el[i] === null) el[i] = 0;
          return el
        })
        rows = [...Array(30).keys()].map((i) => {
          const xDaysPast = new Date().setDate(new Date().getDate() - (30 - (i + 1)))
          const dateThen = moment(String(new Date(xDaysPast))).format("DD-MM-YY").toString()
          return rows.find(el => el.event_date == dateThen) ?? template(dateThen)
        })
        response.ok(rows, res)
      }
    })
  } else response.fail("Unauthorized", res)
}

exports.addProcurement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [2])
  if (user) {
    const query = "INSERT INTO procurement (generated_id, quantity, note, item_id, requested_by) VALUES(?, ?, ?, ?, ?)"
    connection.query(query, [req.body.generated_id, req.body.quantity, req.body.note, req.body.item_id, user.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Procurement success", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.acceptProcurement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "UPDATE procurement SET date_accepted=? WHERE id=?"
    connection.query(query, [new Date(), req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Procurement proposal accepted", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.rejectProcurement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "UPDATE procurement SET date_rejected=?, reason=? WHERE id=?"
    connection.query(query, [new Date(), req.body.reason, req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Procurement proposal denied", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.orderProcurement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "UPDATE procurement SET date_ordered=? WHERE id=?"
    connection.query(query, [new Date(), req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Procurement process started", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}
exports.doneProcurement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [3])
  if (user) {
    const query = "UPDATE procurement SET date_procured=?, date_exp=?, procured_by=? WHERE id=?"
    connection.query(query, [new Date(), req.body.date_exp, user.id, req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Procurement process finished", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.dismissExpirement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [3])
  if (user) {
    const query = "UPDATE procurement SET is_dismissed=1 WHERE id=?"
    connection.query(query, [req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Expirement dismissed", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.returnProcurement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [3])
  if (user) {
    const query = "INSERT INTO returned (procurement_id, quantity, note) VALUES (?, ?, ?)"
    connection.query(query, [req.params.id, req.body.quantity, req.body.reason], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Procurement items returned", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.getAllProcurement = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1, 2, 3])
  if (user) {
    const query = "SELECT p.*, i.name AS item_name, i.vendor, c.id AS category_id, c.name AS category, u.name AS requestee, (SELECT name FROM user WHERE id = p.procured_by) AS procuror_name, r.quantity AS return_amount, r.note AS return_note, i.master_unit_id AS unit_id, un.name AS unit_type " +
      "FROM procurement p JOIN item i ON p.item_id = i.id " +
      "JOIN master_category c ON c.id = i.master_category_id " +
      "JOIN master_unit un ON un.id = i.master_unit_id " +
      "JOIN user u ON p.requested_by = u.id " +
      "LEFT JOIN returned r ON r.procurement_id = p.id " +
      "WHERE p.date_proposal >= ? AND p.date_proposal <= ? " +
      "ORDER BY p.id DESC"
    connection.query(query, [req.query.sdate, req.query.edate], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok(rows, res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.addItem = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "INSERT INTO item (name, master_category_id, master_unit_id, vendor) VALUES (?, ?, ?, ?)"
    connection.query(query, [req.body.name, req.body.category_id, req.body.unit_id, req.body.vendor], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Added new item", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.updateItem = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "UPDATE item SET name=?, master_category_id=?, master_unit_id=?, vendor=? WHERE id=?"
    connection.query(query, [req.body.name, req.body.master_category_id, req.body.master_unit_id, req.body.vendor, req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Item info updated", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.deleteItem = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "DELETE FROM item WHERE id=?"
    connection.query(query, [req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Item deleted", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.getAllItems = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1, 2, 3])
  if (user) {
    const query = "SELECT i.*, c.name AS category_name, u.name AS unit_name FROM item i JOIN master_category c ON c.id = i.master_category_id JOIN master_unit u ON u.id = i.master_unit_id ORDER BY i.name"
    connection.query(query, (error, rows, fields) => {
      if (error) response.fail(error, res)
      else {
        const items = []
        for (let i = 0; i < rows.length; i++) {
          checkQuantity(req.query.date, rows[i].id, item => {
            if(!item.quantity) item.quantity = 0
            item.date_created = rows.find(el => el.id == item.id).date_created
            item.category = {
              id: rows.find(el => el.id == item.id).master_category_id,
              name: rows.find(el => el.id == item.id).category_name
            }
            item.unit = {
              id: rows.find(el => el.id == item.id).master_unit_id,
              name: rows.find(el => el.id == item.id).unit_name,
            }
            items.push(item)
            if(items.length == rows.length) response.ok(items, res)
          })
        }
      }
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

const checkQuantity = async (date, id, resolve) => {
  if(!date) date = '2099-12-31'
  let query = "SELECT SUM(p.quantity) AS quantity, SUM(r.quantity) AS return_amount, SUM(p.quantity_out) AS quantity_out, i.id, i.name, i.vendor " +
    "FROM procurement p " +
    "JOIN item i ON i.id = p.item_id " +
    "LEFT JOIN returned r ON r.procurement_id = p.id " +
    "WHERE p.date_procured <= ? AND i.id = ? LIMIT 1";
  const quantityProc = (await connection.promise().query(query, [date, id]))[0][0]
  query = "SELECT * FROM procurement p WHERE item_id=? ORDER BY date_exp ASC"
  let firstExp = (await connection.promise().query(query, [id]))[0]
  firstExp = firstExp.filter(el => el.quantity - (el.quantity_out || 0) > 0)
  query = "SELECT SUM(pu.quantity) AS quantity FROM purchase pu WHERE pu.date_purchase <= ? AND pu.item_id = ? LIMIT 1"
  const quantityPurchase = (await connection.promise().query(query, [date, id]))[0][0]
  resolve({
    id: id,
    name: quantityProc.name,
    vendor: quantityProc.vendor,
    quantity: quantityProc.quantity - quantityProc.return_amount - quantityProc.quantity_out,
    qty_by_date: quantityProc.quantity - quantityProc.return_amount - quantityPurchase.quantity,
    hasExpiring: firstExp
  })
}

exports.addPurchase = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [3])
  if (user) {
    checkQuantity('', req.body.item_id, item => {
      if (item.quantity - req.body.quantity >= 0) {
        let reqQty = req.body.quantity
        for(let i = 0; i < item.hasExpiring.length; i++) {
          const qtyOut = parseFloat((item.hasExpiring[i].quantity_out || 0) + reqQty)
          console.log("current proc", item.hasExpiring[i].quantity_out)
          const query = "UPDATE procurement SET quantity_out=? WHERE id=?"
          if(qtyOut <= item.hasExpiring[i].quantity) {
            console.log("qty out", qtyOut)
            connection.query(query, [qtyOut, item.hasExpiring[i].id])
            break
          } else {
            console.log("qty max reached", item.hasExpiring[i].quantity)
            connection.query(query, [item.hasExpiring[i].quantity, item.hasExpiring[i].id])
            reqQty -= parseFloat(item.hasExpiring[i].quantity - item.hasExpiring[i].quantity_out)
          }
        }
        const query = "INSERT INTO purchase (item_id, quantity, note, handler_id) VALUES (?, ?, ?, ?)"
        connection.query(query, [req.body.item_id, req.body.quantity, req.body.note, user.id], (error, rows, fields) => {
          if (error) response.fail(error, res)
          else response.ok("Purchase data added", res)
        })
      } else {
        response.fail("Insufficient quantity", res)
      }
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.getAllPurchase = (req, res) => {
  const access = [3],
    { admin } = req.query
  if (admin == 'true') access.unshift(1)
  const user = handle.routeAccess(req.headers.token, access)
  if (!user) response.fail("Unauthorized", res)

  const query = "SELECT pu.*, i.name, i.vendor, c.id AS cat_id, c.name AS cat_name, u.name AS handler_name, un.name AS unit_name FROM purchase pu JOIN item i ON i.id = pu.item_id JOIN master_category c ON c.id = i.master_category_id JOIN user u ON pu.handler_id = u.id JOIN master_unit un ON un.id = i.master_unit_id WHERE pu.date_purchase >= ? AND pu.date_purchase <= ?"
  connection.query(query, [req.query.sdate, req.query.edate], (error, rows, fields) => {
    if (error) response.fail(error, res)
    else response.ok(rows, res)
  })
}

exports.getAllReturnedItems = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1, 3])
  if (user) {
    const query = "SELECT p.*, i.name AS item_name, i.vendor, c.id AS category_id, c.name AS category, u.name AS requestee, (SELECT name FROM user WHERE id = p.procured_by) AS procuror_name, r.quantity AS return_amount, r.note AS return_note, i.master_unit_id AS unit_id, un.name AS unit_type " +
      "FROM procurement p JOIN item i ON p.item_id = i.id " +
      "JOIN master_category c ON c.id = i.master_category_id " +
      "JOIN master_unit un ON un.id = i.master_unit_id " +
      "JOIN user u ON p.requested_by = u.id " +
      "LEFT JOIN returned r ON r.procurement_id = p.id " +
      "WHERE p.date_proposal >= ? AND p.date_proposal <= ? " +
      "AND r.quantity IS NOT NULL"
      "ORDER BY p.id DESC"
    connection.query(query, [req.query.sdate, req.query.edate], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok(rows, res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.addMasterCategory = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "INSERT INTO master_category (name) VALUES (?)"
    connection.query(query, [req.body.name], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Added new category", res)
    })
  } else response.fail("Unauthorized", res)
}

exports.getMasterCategory = (req, res) => {
  const query = "SELECT * FROM master_category"
  connection.query(query, (error, rows, fields) => {
    if (error) response.fail(error, res)
    else response.ok(rows, res)
  })
}

exports.addMasterUnit = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user) {
    const query = "INSERT INTO master_unit (name) VALUES (?)"
    connection.query(query, [req.body.name], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Added new unit", res)
    })
  } else response.fail("Unauthorized", res)
}

exports.getMasterUnit = (req, res) => {
  const query = "SELECT * FROM master_unit"
  connection.query(query, (error, rows, fields) => {
    if (error) response.fail(error, res)
    else response.ok(rows, res)
  })
}

exports.getMasterRole = (req, res) => {
  const query = "SELECT * FROM master_role"
  connection.query(query, (error, rows, fields) => {
    if (error) response.fail(error, res)
    else response.ok(rows, res)
  })
}

exports.getUser = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1, 2, 3])
  if (user.id == req.params.id) {
    const query = "SELECT u.*, r.name FROM user u JOIN master_role r ON u.master_role_id = r.id WHERE u.id = ? LIMIT 1"
    connection.query(query, [req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok(rows[0], res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.editUser = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1, 2, 3])
  if (user.id == req.params.id || user.role_id == 1) {
    let query
    let params
    if (req.body.password) {
      const password = bcrypt.hashSync(req.body.password, 10)
      query = "UPDATE user SET password=?, name=?, id_npwp=? WHERE id=?"
      params = [password, req.body.name, req.body.id_npwp, req.params.id]
    } else {
      query = "UPDATE user SET name=?, id_npwp=? WHERE id=?"
      params = [req.body.name, req.body.id_npwp, req.params.id]
    } 
    connection.query(query, params, (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok("Success edit profile", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.activateUser = async (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1])
  if (user.role_id == 1) {
    const selectedUser = await new Promise(resolve => connection.query("SELECT is_active FROM user WHERE id=? LIMIT 1", [req.params.id], (error, rows, fields) => resolve(error ? error : rows)))
    const activateUser = selectedUser[0].is_active == 1 ? 0 : 1
    const query = `UPDATE user SET is_active=${activateUser} WHERE id=${req.params.id}` 
    connection.query(query, (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok(activateUser == 1 ? "Success activate account" : "Account deactivated", res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.getUserLog = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1, 2, 3])
  if (user.id == req.params.id || user.role_id == 1) {
    const query = "SELECT * FROM log_history WHERE user_id = ?"
    connection.query(query, [req.params.id], (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok(rows, res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.getAllUser = (req, res) => {
  const user = handle.routeAccess(req.headers.token, [1]) 
  if (user){
    const query = "SELECT u.id, u.username, u.name, u.id_npwp, u.master_role_id, u.is_active, r.name AS role FROM user u JOIN master_role r ON u.master_role_id = r.id"
    connection.query(query, (error, rows, fields) => {
      if (error) response.fail(error, res)
      else response.ok(rows, res)
    })
  } else {
    response.fail("Unauthorized", res)
  }
}

exports.index = (req, res) => {
  response.ok("Hello from the Node JS RESTful side!", res)
}