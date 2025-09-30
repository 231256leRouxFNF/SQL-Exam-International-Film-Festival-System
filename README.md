# SQL-Exam-International-Film-Festival-System

International Film Festival Database
Overview

This repository contains the SQL database design and implementation for an International Film Festival.
The database tracks:

Films, categories, directors, producers, cast, and countries of collaboration

Screenings across multiple venues and assigned seats

Audience ticket purchases

Jury members, scores, and award nominations

Sponsors and sponsorships for specific events and categories

The project includes:

Database schema with primary and foreign keys

Sample data for testing

Joins to query relationships between tables

Triggers for enforcing business rules

Stored procedures for common operations

# Tables

| Table Name       | Description |
|-----------------|-------------|
| `film`           | Stores information about films, including title, category, release year, and duration |
| `category`       | Types of films (feature film, documentary, short film) |
| `person`         | Stores directors, producers, and cast members |
| `filmperson`     | Associates people with films and their roles |
| `country`        | Countries involved in film collaborations |
| `filmlocation`   | Connects films to countries for international collaborations |
| `screening`      | Details of film screenings across venues |
| `venue`          | Venue details including capacity and address |
| `seat`           | Individual seats in venues |
| `ticket`         | Tickets purchased by audience members |
| `audience`       | Festival audience members |
| `jurymember`     | Jury members scoring films |
| `juryscore`      | Jury scores and comments for films |
| `awardcategory`  | Categories for awards (e.g., Best Director) |
| `award`          | Award results for films and people |
| `sponsor`        | Sponsors of the festival |
| `sponsorship`    | Sponsorship amounts for specific events and award categories |
| `event`          | Festival events |


## Key Features
  
1. **Joins**
 -   Films with screenings in multi venues
 -   International collaborations so one film with 3 countries
 -   Tickets per screening with audience and seat info

2. **Triggers**
   - Prevent double-booking of seats
   - Validate screening times
   - Automatically set ticket purchase timestamp

3. **Stored Procedures**
   - Generate award nominees based on jury scores
   - List all screenings for a specific film
   - Calculate total sponsorship by award category

---

## Getting Started

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/film-festival-db.git
cd film-festival-db
Import the database

Open your MariaDB/MySQL client or phpMyAdmin

Create a new database, e.g., international_film_festival_db

Import the provided SQL file:

sql
Copy
Edit
SOURCE path/to/film_festival_fixed.sql;
Test the database

Run sample joins:

sql
Copy
Edit
SELECT f.title, v.name AS venue_name, s.starts_at
FROM film f
JOIN screening s ON f.film_id = s.film_id
JOIN venue v ON s.venue_id = v.venue_id;
Call stored procedures:

sql
Copy
Edit
CALL get_nominees(8);




