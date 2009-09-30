/**
 * Copyright (C) 2009 WebShape
 * Use, modification and distribution is subject to the GPL license
 *
 * @fileoverview
 * General utilities to write js code
 * @author Dissegna Stefano
 */

/**
 * Define reader function getSlot
 * @param {String} slot name of the slot
 * @param {String} publicName public name of the slot (optional)
 */
Function.prototype.reader = function (slot, publicName) {
  this.prototype[publicName || 'get' + slot] = function () {
    return this[slot];
  };
};

/**
 * Define writer function setSlot(x)
 * @param {String} slot name of the slot
 * @param {String} publicName public name of the slot (optional)
 */
Function.prototype.writer = function (slot, publicName) {
  this.prototype[publicName || 'set' + slot] = function (x) {
    return (this[slot] = x);
  };
};

/**
 * Define accessors functions getSlot and setSlot(x)
 * @param {String} slot name of the slot
 * @param {String} readName name of the reader function (optional)
 * @param {String} writeName name of the writer function (optional)
 */
Function.prototype.accessors = function (slot, readName, writeName) {
  this.prototype[readName || 'get' + slot] = function () {
    return this[slot];
  };
  this.prototype[writeName || 'set' + slot] = function (x) {
    return (this[slot] = x);
  };
};

/**
 * Apply a function to each element of an array
 * @param {Function} fn function to apply. fn should accept one argument
 */
Array.prototype.each = function (fn) {
  for (var i = 0; i < this.length; ++i) {
    fn.call(this, this[i]);
  }
};

/**
 * Build a new array mapping a function to each element
 * @param {Function} fn function to apply
 * @return the new array
 */
Array.prototype.map = function (fn) {
  var res = [];
  for (var i = 0; i<this.length; ++i) {
    res.push(fn.call(this, this[i]));
  }

  return res;
};

/**
 * Build a new array without elements for which the predicate doesn't hold
 * @param {Function} fn predicate
 * @return the new array
 */
Array.prototype.grep = function (fn) {
  var res = [];
  for (var i = 0; i<this.length; ++i) {
    if (fn.call(this, this[i])) {
      res.push(this[i]);
    }
  }

  return res;
};
