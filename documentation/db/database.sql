create table users (
  userid serial not null primary key,
  name character not null,
  email character not null,
  "password" character,
  userIdAuth text not null
);

create table categories (
  categoryid serial not null primary key,
  name character not null,
  description text,
  status boolean,
  userId integer references users (userid)
);

create table products (
  productid serial not null primary key,
  categoryid integer references categories (categoryid),
  product_name character not null,
  description text,
  quantity integer not null,
  status boolean,
  userId integer references users (userid)
);

create table orders (
  orderid serial not null primary key,
  productid integer references products (productid),
  order_date timestamp default now(),
  quantity integer not null,
  remaining_quantity integer,
  sale_price numeric,
  purchase_price numeric,
  status boolean not null
);

create table sales (
  saleid serial not null primary key,
  orderid integer references orders (orderid),
  sale_date timestamp default now(),
  quantity integer not null,
  status boolean
);

create table productimages (
  productimageid serial not null primary key,
  productid integer references products (productid),
  url text not null
);
