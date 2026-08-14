const mongoose = require('mongoose');

const CustomListSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    name: { type: String, required: true, trim: true },
    items: [{ type: String }], // Array of imdbIds
  },
  { timestamps: true }
);

module.exports = mongoose.model('CustomList', CustomListSchema);