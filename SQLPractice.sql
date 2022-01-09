use sakila;

-- Display the first and last names of all actors from the table actor.
select first_name, last_name
from actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, " ", last_name) as Actor_Name
from actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

-- Find all actors whose last name contain the letters GEN
select * 
from actor
where last_name like '%GEN%';

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
select last_name, first_name
from actor
where last_name like '%LI%';

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ("afghanistan", "bangladesh", "china");

-- You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
add description blob;

-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column description;

-- List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as how_many
from actor
group by last_name;

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as how_many
from actor
group by last_name
having how_many > 1;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor 
set first_name = 'HARPO', last_name = 'WILLIAMS'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name = 'GROUCHO', last_name = 'WILLIAMS'
where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address
from staff s
inner join address a
on s.address_id = a.address_id;

-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select sum(p.amount) as total_rung, s.first_name, s.last_name
from payment p
inner join staff s
on p.staff_id = s.staff_id
where payment_date like "2005-08%"
group by first_name, last_name;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title, count(actor_id) as number_actors
from film f
inner join film_actor fa
on f.film_id = fa.film_id
group by title;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
select count(inventory_id) as num_copies
from inventory
where film_id =
(
select film_id
from film
where title = 'Hunchback Impossible'
);

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
select c.last_name, c.first_name, sum(p.amount) as amount_payed
from customer c 
join payment p
on c.customer_id = p.customer_id
group by last_name, first_name
order by last_name ASC;

-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film
where title like'K%' or title like 'Q%'
and language_id =
(
select language_id
from language
where name = 'English'
);

-- Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id in
(
select actor_id
from film_actor
where film_id =
(select film_id
from film
where title = 'Alone Trip'
));

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email
from customer c
inner join address a
on c.address_id = a.address_id
inner join city ct
on a.city_id = ct.city_id
inner join country co
on ct.country_id = co.country_id
where country = 'Canada';

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select f.film_id, f.title
from film f
inner join film_category fc
on f.film_id = fc.film_id
inner join category c
on fc.category_id = c.category_id
where name = 'Family';

-- Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) as num_rented
from film f
inner join inventory i 
on f.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
group by f.title
order by num_rented desc;

-- Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as total_revenue
from store s
inner join staff st
on s.store_id = st.store_id
inner join payment p
on st.staff_id = p.staff_id
group by store_id;

-- Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, co.country
from store s
inner join address a
on s.address_id = a.address_id
inner join city c
on a.city_id = c.city_id
inner join country co
on c.country_id = co.country_id;

-- List the top five genres in gross revenue in descending order (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount) as gross_revenue
from category c
inner join film_category fc
on c.category_id = fc.category_id
inner join inventory i 
on fc.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
inner join payment p
on r.rental_id = p.rental_id
group by name
order by gross_revenue desc
limit 5;

-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view
create view top_five_genres as 
select c.name, sum(p.amount) as gross_revenue
from category c
inner join film_category fc
on c.category_id = fc.category_id
inner join inventory i 
on fc.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
inner join payment p
on r.rental_id = p.rental_id
group by name
order by gross_revenue desc
limit 5;

-- How would you display the view that you created in 8a?
select * from top_five_genres;

-- you find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres
