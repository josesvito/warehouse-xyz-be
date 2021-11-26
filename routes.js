'use strict';

module.exports = function(app) {
  const todoList = require('./controller')

  app.get('/', todoList.index)

  app.post('/users/session/login', todoList.login)

  app.post('/users/session/logout', todoList.logout)

  app.get('/users/list', todoList.getAllUser)

  app.get('/product/dashboard', todoList.getDashboardChart)

  app.get('/product/list', todoList.getAllItems)

  app.post('/product/add', todoList.addItem)

  app.post('/product/purchase', todoList.addPurchase)

  app.patch('/product/:id', todoList.updateItem)

  app.delete('/product/:id', todoList.deleteItem)

  app.get('/product/procurement', todoList.getAllProcurement)

  app.post('/product/procurement', todoList.addProcurement)

  app.patch('/product/procurement/:id/acc', todoList.acceptProcurement)

  app.patch('/product/procurement/:id/dec', todoList.rejectProcurement)

  app.patch('/product/procurement/:id/order', todoList.orderProcurement)

  app.patch('/product/procurement/:id/done', todoList.doneProcurement)

  app.patch('/product/procurement/:id/dis', todoList.dismissExpirement)

  app.post('/product/procurement/:id', todoList.returnProcurement)

  app.get('/product/purchase', todoList.getAllPurchase)

  app.get('/product/returned', todoList.getAllReturnedItems)

  app.get('/master/role', () => {})

  app.get('/master/item_category', todoList.getMasterCategory)

  app.post('/master/item_category', todoList.addMasterCategory)

  app.get('/master/item_unit', todoList.getMasterUnit)

  app.post('/master/item_unit', todoList.addMasterUnit)

  app.get('/users/profile/:id', todoList.getUser)

  app.patch('/users/profile/:id', todoList.editUser)

  app.put('/users/profile/:id', todoList.activateUser)

  app.get('/users/profile/:id/log', todoList.getUserLog)

  app.get('/help', function(req, res) {
    // TODO buat halaman untuk panduan route API beserta param yg dibutuhkan
    // var path = require('path')
    // res.sendFile(path.join(__dirname + "/tests/dummy.html"))
  })

  app.all('*', function(req, res) {
    const response = require('./res')
    response.fail("Route unavailable", res)
  })
};