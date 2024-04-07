"use strict";

/**
 * blog controller
 */

const { createCoreController } = require("@strapi/strapi").factories;
module.exports = createCoreController("api::blog.blog", ({ strapi }) => ({
  async findOne(ctx) {
    const { id } = ctx.params;

    let entity = await strapi.db.query("api::blog.blog").findOne({
      where: { slug: id },
      populate: true,
    });

    const sanitiedEntity = await this.sanitizeOutput(entity, ctx);

    return this.transformResponse(sanitiedEntity);
  },

  async category(ctx) {
    const { slug } = ctx.query;
    let currentPage = parseInt(ctx.query.page) || 1;
    let pageSize = parseInt(ctx.query.pageSize) || 10;

    const categories = await strapi.db.query("api::category.category").findOne({
      where: { slug: slug },
    });

    const blogs = await strapi.db.query("api::blog.blog").findPage({
      where: { category: categories.id },
      populate: true,
      page: currentPage,
      pageSize: pageSize,
    });
    const data = await this.sanitizeOutput(blogs.results, ctx);
    const meta = {
      pagination: blogs.pagination,
      category: categories.category_name,
    };
    return { data, meta };
  },
}));
