'use strict';

exports.ok = (values, res) => {
  const data = {
    'status': 1,
    'message': 'success',
    'values': values
  };
  res.json(data);
  res.end();
};

exports.fail = (values, res) => {
  const data = {
    'status': 0,
    'message': "fail",
    'values': values
  };
  res.json(data);
  res.end();
}