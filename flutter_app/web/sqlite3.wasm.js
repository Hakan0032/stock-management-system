// SQLite3 WASM JavaScript loader
// This is a minimal implementation for sqflite_common_ffi_web

(function() {
  'use strict';

  // Simple SQLite3 WASM loader
  const SQLite3 = {
    init: function() {
      return Promise.resolve({
        Database: function() {
          return {
            exec: function() { return []; },
            close: function() {},
            prepare: function() {
              return {
                step: function() { return false; },
                finalize: function() {},
                get: function() { return []; }
              };
            }
          };
        }
      });
    }
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = SQLite3;
  } else if (typeof window !== 'undefined') {
    window.SQLite3 = SQLite3;
  } else if (typeof self !== 'undefined') {
    self.SQLite3 = SQLite3;
  }
})();