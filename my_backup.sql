SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES
	('00000000-0000-0000-0000-000000000000', '0b5837b6-97b2-43b4-ac5f-63d650953987', '{"action":"user_confirmation_requested","actor_id":"53c6d884-ac92-47a6-8519-ecad9790fff6","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-08-17 15:33:16.212815+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a48ddb4f-761a-4ba4-8ab4-7011185f0c1d', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"aa@aa.com","user_id":"53c6d884-ac92-47a6-8519-ecad9790fff6","user_phone":""}}', '2025-08-17 15:54:01.043724+00', ''),
	('00000000-0000-0000-0000-000000000000', '3129e20e-84d6-4cb5-81a0-71e040108005', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"aa@aa.com","user_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","user_phone":""}}', '2025-08-17 15:54:26.578126+00', ''),
	('00000000-0000-0000-0000-000000000000', '5dd4f550-30aa-48a6-9d7f-0f82dbba0aa6', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"bb@bb.com","user_id":"b59b151a-ae98-47b6-8855-348655223d76","user_phone":""}}', '2025-08-17 15:54:49.709286+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e3f3293b-1cbc-4b8c-82ed-2edd700ab1fd', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 16:03:13.07183+00', ''),
	('00000000-0000-0000-0000-000000000000', '8f43405d-efed-4dec-bc28-b961d14e3ccb', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-17 16:05:19.541724+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c4442bc9-0fe6-4f94-8808-e0faeeadcc18', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 16:07:27.555195+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c69e50e0-6ff4-4b0c-9e6b-01ef40c52a86', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 16:14:32.308497+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e229d0d9-06de-4392-9e5b-e25f35658d5f', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-17 16:15:19.26912+00', ''),
	('00000000-0000-0000-0000-000000000000', '3f737084-69df-49fb-a25a-eb71ac44efc2', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 16:15:34.992307+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a30d7f3c-0f3b-4749-9ee3-b5f7af224f0c', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-17 16:17:41.991333+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bbaef4ae-8682-4378-a656-11d509e0c210', '{"action":"login","actor_id":"b59b151a-ae98-47b6-8855-348655223d76","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 16:20:04.335009+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd3cae1ef-8e7d-4ede-9af3-6d32b3a27fc3', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 16:37:50.610336+00', ''),
	('00000000-0000-0000-0000-000000000000', '52e64cfa-7502-4f02-8a8d-f0c86faf00df', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 17:26:49.892139+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f54aaca1-4723-4ddd-a6fa-063b3bbdac06', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 17:29:08.345091+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f79a8450-e914-4ce6-bd54-c249ba3129a6', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 17:38:29.317382+00', ''),
	('00000000-0000-0000-0000-000000000000', '1357d301-cc82-49ec-922f-9581a73b52a1', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 17:52:16.774818+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e352aef8-d672-4e36-88df-31a28b0638ab', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-17 17:55:04.590614+00', ''),
	('00000000-0000-0000-0000-000000000000', '5b61cb64-8411-4d73-8a57-44981bb9ca3a', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 17:55:16.161849+00', ''),
	('00000000-0000-0000-0000-000000000000', '61f37f71-7b9b-4fa7-970b-ce96a0f2211b', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-17 17:59:52.827792+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dd8e613c-099d-4922-a5d6-90db44043e85', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 18:00:09.781834+00', ''),
	('00000000-0000-0000-0000-000000000000', '7d047313-62f0-43de-b9c8-35393259da9f', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 18:01:49.006051+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b265987c-d352-461f-9d0d-433af325289d', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-17 18:01:57.976485+00', ''),
	('00000000-0000-0000-0000-000000000000', '15702622-fdfa-4c59-9d22-711ebb71e673', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 18:06:38.863805+00', ''),
	('00000000-0000-0000-0000-000000000000', '4ec82876-0302-401a-9805-f7fe7a9e0229', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 18:42:14.703716+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bd411b3b-50d3-4f3f-a79a-9719b380ea45', '{"action":"token_refreshed","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-17 19:41:39.147418+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b9d2bce4-9c99-48e7-957b-b638e958cd72', '{"action":"token_revoked","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-17 19:41:39.166041+00', ''),
	('00000000-0000-0000-0000-000000000000', '38c5c01e-268d-4a64-a258-8963f45f8fca', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 20:33:01.739234+00', ''),
	('00000000-0000-0000-0000-000000000000', '34811dcb-fe59-4d21-b186-b8e6d9d6f7c7', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 21:05:09.580565+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c7d30b80-aa0c-47dd-9220-d941dadcbc66', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 21:31:43.116244+00', ''),
	('00000000-0000-0000-0000-000000000000', '4fed6ba2-6aba-4cda-9c1c-cd11c678e5b9', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 21:43:51.91314+00', ''),
	('00000000-0000-0000-0000-000000000000', '04423a3c-ade1-4cc2-b26e-1f2474bd0542', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-17 22:21:49.130897+00', ''),
	('00000000-0000-0000-0000-000000000000', '1d877338-2a13-4cde-8791-a878320155a7', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-18 16:43:46.950924+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f2b234c3-fb12-4477-a0f5-4a6766853344', '{"action":"token_refreshed","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 11:31:59.305857+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c3098a8a-6c11-44e1-ba18-6be4539e5765', '{"action":"token_revoked","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 11:31:59.33347+00', ''),
	('00000000-0000-0000-0000-000000000000', '06265bbc-15bb-46ad-9728-2c67ec74e27a', '{"action":"token_refreshed","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 12:31:26.229851+00', ''),
	('00000000-0000-0000-0000-000000000000', '7a1b02bf-8d03-4813-a98e-1cfc335305b0', '{"action":"token_revoked","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 12:31:26.259652+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a12ffc0a-9cc3-4c8c-b1c4-8dba9cea2673', '{"action":"token_refreshed","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 13:30:54.769666+00', ''),
	('00000000-0000-0000-0000-000000000000', '1c27abd2-8137-4b14-bb53-303fbcb33e51', '{"action":"token_revoked","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 13:30:54.787126+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f5021f68-67d6-4ca2-abd8-a7c65929be94', '{"action":"token_refreshed","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 14:30:22.59823+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fe56eeac-b6e8-4fbb-b131-7c58fa967c59', '{"action":"token_revoked","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 14:30:22.616522+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a29549d1-78bc-4e6a-8019-abaf0c569696', '{"action":"token_refreshed","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 15:29:53.219408+00', ''),
	('00000000-0000-0000-0000-000000000000', '2b39f739-477d-4643-b367-ecb4dd8443a9', '{"action":"token_revoked","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-19 15:29:53.239843+00', ''),
	('00000000-0000-0000-0000-000000000000', '28b95f1f-c74a-434c-8bc2-f862f0590f7d', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-19 15:39:42.816044+00', ''),
	('00000000-0000-0000-0000-000000000000', '98c17d76-4124-406d-9f81-44efbd1a9237', '{"action":"login","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-19 15:41:47.347895+00', ''),
	('00000000-0000-0000-0000-000000000000', '479e2bdc-e7f0-41f4-b4d4-0ff5048b5968', '{"action":"logout","actor_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-19 16:00:53.380165+00', ''),
	('00000000-0000-0000-0000-000000000000', '29e9873d-419c-486f-9953-72c84544fd81', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"aa@aa.com","user_id":"1b648960-b270-4fd3-b4f8-59c9f98c5522","user_phone":""}}', '2025-08-19 16:08:30.869188+00', ''),
	('00000000-0000-0000-0000-000000000000', 'efd5ca59-d8c0-464f-806d-53d59bee1645', '{"action":"user_confirmation_requested","actor_id":"3622b3c6-3206-47cc-a3f9-bea14c52e0b9","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-08-19 16:17:40.666651+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b0c7f730-6bf6-454d-bdcc-d88adb4d31ee', '{"action":"user_confirmation_requested","actor_id":"3622b3c6-3206-47cc-a3f9-bea14c52e0b9","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-08-19 16:18:44.231776+00', ''),
	('00000000-0000-0000-0000-000000000000', '0e167f91-7163-4829-a8f4-a3c169e0cedf', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"ab@aa.com","user_id":"3622b3c6-3206-47cc-a3f9-bea14c52e0b9","user_phone":""}}', '2025-08-19 16:27:10.230958+00', ''),
	('00000000-0000-0000-0000-000000000000', '049179ff-0db7-4a1e-9ac5-e0898eefd469', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"bb@bb.com","user_id":"b59b151a-ae98-47b6-8855-348655223d76","user_phone":""}}', '2025-08-19 16:27:23.05825+00', ''),
	('00000000-0000-0000-0000-000000000000', '6e5c8940-1975-4366-891d-272888bac815', '{"action":"user_confirmation_requested","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-08-19 16:28:23.459602+00', ''),
	('00000000-0000-0000-0000-000000000000', '9ec3f97f-762d-4757-81d7-f277e0a5b1cc', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"aa@aa.com","user_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","user_phone":""}}', '2025-08-19 16:47:55.541386+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bf0efbc9-8910-4cd3-8593-b5127d17fc8d', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-19 16:48:19.86159+00', ''),
	('00000000-0000-0000-0000-000000000000', '0c553433-7406-4dc8-8361-ae9a1b876d0e', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-19 16:57:57.470724+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b9c51212-b3fd-4ebb-80ec-7f0fe6c56c95', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-19 17:03:01.326578+00', ''),
	('00000000-0000-0000-0000-000000000000', '7e1de10a-b6e6-4724-b701-9ff2f46e97a1', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 02:06:57.564782+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd0915f4c-7c52-4ba6-9316-0b7a5860fb82', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 02:06:57.584254+00', ''),
	('00000000-0000-0000-0000-000000000000', '85a7c0bc-3832-40a1-b2c2-3c85fe1c9a9b', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 02:59:29.82254+00', ''),
	('00000000-0000-0000-0000-000000000000', '78f8a736-e5b3-49d9-8e22-44ccf97a2253', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 03:14:47.662883+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ed3bba80-e13e-4fa9-8bc6-2b4fdc957376', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 03:26:24.337758+00', ''),
	('00000000-0000-0000-0000-000000000000', '6f041778-dcdf-4b24-8277-7c29bfe7307d', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 04:11:54.645194+00', ''),
	('00000000-0000-0000-0000-000000000000', '4d49c892-45cb-4066-82da-6b4df690aea5', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 04:31:12.211253+00', ''),
	('00000000-0000-0000-0000-000000000000', '4004b068-7de4-4c5f-a2d3-84bf97014a72', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 04:31:12.216891+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fc8ebba7-0258-4d8c-adb3-2ca4be6ba545', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 04:32:19.344646+00', ''),
	('00000000-0000-0000-0000-000000000000', '460ca67a-22aa-4277-a298-85dc0955fb18', '{"action":"login","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 04:32:43.981212+00', ''),
	('00000000-0000-0000-0000-000000000000', '146d5509-fc14-4e2c-98d5-eb8d22cdf205', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 04:53:32.236047+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bc960138-511e-4035-9493-27b56cec67e3', '{"action":"token_refreshed","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 08:04:25.806653+00', ''),
	('00000000-0000-0000-0000-000000000000', '5818ff43-21dc-4eeb-b8cb-de2b719b0a4e', '{"action":"token_revoked","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 08:04:25.83333+00', ''),
	('00000000-0000-0000-0000-000000000000', 'abd58152-3f94-4fa5-91e8-8a8d6452e376', '{"action":"token_refreshed","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 09:03:50.428792+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd1ec32e3-cb26-4c3b-975d-18541227e7a2', '{"action":"token_revoked","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 09:03:50.453461+00', ''),
	('00000000-0000-0000-0000-000000000000', '00bc2431-1303-445e-bcc0-67c8712d6c68', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 09:36:37.63155+00', ''),
	('00000000-0000-0000-0000-000000000000', '4d9350eb-4999-44bc-abe2-709682dd03c4', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 09:39:49.036626+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e97d9fb7-7161-4815-b097-b50f7f63b902', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 09:40:23.293493+00', ''),
	('00000000-0000-0000-0000-000000000000', 'df7a0a01-bfe6-4d94-9e5f-947793b6ebc7', '{"action":"login","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 09:44:01.798259+00', ''),
	('00000000-0000-0000-0000-000000000000', '6c560097-bb43-4f53-b9cc-fcd753248c9b', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 09:44:57.845217+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a8eec007-dc7c-4ef6-b237-004cef0069b2', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 09:45:08.951732+00', ''),
	('00000000-0000-0000-0000-000000000000', '46d893d3-ad7d-4598-a413-8f11bc0bf681', '{"action":"logout","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 09:46:47.616379+00', ''),
	('00000000-0000-0000-0000-000000000000', '4aedad3b-07aa-4533-bee5-f5a0f36e7c07', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 10:04:27.056726+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c986dffe-6c27-443f-85d6-c294768f3e23', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 10:04:37.910898+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a1a7de4b-4cf3-47a6-aa71-287cbfc2d5d8', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 10:21:40.432585+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f183772c-bffe-42d8-8eb4-4d3ba8da1e07', '{"action":"login","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 10:27:59.550838+00', ''),
	('00000000-0000-0000-0000-000000000000', '3127f9e8-2ad9-49a5-964b-57e7de23bb49', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 11:21:08.487013+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c792c86d-9d59-41ac-b499-2a25afdd4794', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 11:21:08.503804+00', ''),
	('00000000-0000-0000-0000-000000000000', '78ae5346-d6e7-4dca-bb1b-32b3325b804b', '{"action":"token_refreshed","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 11:27:25.28522+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a17051fe-f7c1-48c0-93df-0dafebf021fe', '{"action":"token_revoked","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 11:27:25.290773+00', ''),
	('00000000-0000-0000-0000-000000000000', '0921c019-3f16-4366-8610-32fba486ab20', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 12:20:38.257494+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f5007988-f2a3-431e-90a8-097d35397fbc', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 12:20:38.267238+00', ''),
	('00000000-0000-0000-0000-000000000000', '9630ea92-610b-4232-8feb-46fc2df5ee7a', '{"action":"token_refreshed","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 12:26:54.580309+00', ''),
	('00000000-0000-0000-0000-000000000000', '6132f9f6-5e33-4e61-ba00-395ec2e16e09', '{"action":"token_revoked","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 12:26:54.596542+00', ''),
	('00000000-0000-0000-0000-000000000000', '79ddf48a-af71-46b4-8033-433ec09aaaa5', '{"action":"login","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 17:40:50.642569+00', ''),
	('00000000-0000-0000-0000-000000000000', '2a1fd5a9-ffb1-4b55-96d0-b8fb0c073ffd', '{"action":"user_confirmation_requested","actor_id":"f5e3c200-847f-4eaf-92fd-32ff479b67b9","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}', '2025-08-20 17:42:53.479941+00', ''),
	('00000000-0000-0000-0000-000000000000', '5587cc28-4fa5-4a99-8abb-b10003d63382', '{"action":"logout","actor_id":"fa8dbca3-ce25-4cb4-be55-e412c88dc203","actor_username":"ab@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 18:15:08.952283+00', ''),
	('00000000-0000-0000-0000-000000000000', '36528767-b840-469d-8900-e58b5961c915', '{"action":"user_signedup","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-08-20 18:16:13.093743+00', ''),
	('00000000-0000-0000-0000-000000000000', '9df9f8ab-3e94-4abf-8c8b-00b2aab56183', '{"action":"login","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 18:16:13.106832+00', ''),
	('00000000-0000-0000-0000-000000000000', '5bf4b200-72d6-442f-b362-8204b3b02b55', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"bb@bb.com","user_id":"f5e3c200-847f-4eaf-92fd-32ff479b67b9","user_phone":""}}', '2025-08-20 18:19:37.326727+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ccaeb82d-df3a-4cd1-b5aa-e36b257de3bc', '{"action":"user_signedup","actor_id":"53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-08-20 18:20:04.42999+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a966d6eb-337b-48a6-b6f9-3d92c542b873', '{"action":"login","actor_id":"53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 18:20:04.434029+00', ''),
	('00000000-0000-0000-0000-000000000000', '5b0043cb-6884-46ae-81ba-15f7ee4c2e60', '{"action":"logout","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 18:27:02.304225+00', ''),
	('00000000-0000-0000-0000-000000000000', '4133db07-e0f9-4b46-813f-ab4d8385e2aa', '{"action":"login","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 18:27:21.624357+00', ''),
	('00000000-0000-0000-0000-000000000000', '875b5fbf-24e3-4bfd-abaa-f233d3bdd467', '{"action":"token_refreshed","actor_id":"53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 19:19:39.997027+00', ''),
	('00000000-0000-0000-0000-000000000000', 'abfdb522-db8d-4340-8078-3ff71a331e3c', '{"action":"token_revoked","actor_id":"53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 19:19:40.015625+00', ''),
	('00000000-0000-0000-0000-000000000000', '68762fcb-6c7a-4f2d-af5c-d8f23b707ce4', '{"action":"token_refreshed","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 19:26:48.210842+00', ''),
	('00000000-0000-0000-0000-000000000000', '7cc2aec3-260f-4489-9ed9-2b2e69534125', '{"action":"token_revoked","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 19:26:48.220387+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a5fd6a50-e0c9-4939-9461-31c017f16047', '{"action":"token_refreshed","actor_id":"53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 20:19:09.925406+00', ''),
	('00000000-0000-0000-0000-000000000000', '295cdd56-28b2-4d30-b789-f1effcd8ad4b', '{"action":"token_revoked","actor_id":"53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 20:19:09.936232+00', ''),
	('00000000-0000-0000-0000-000000000000', '4c3e81f3-95e5-4cb7-be4f-2d304e0f5fe8', '{"action":"token_refreshed","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 20:26:18.159254+00', ''),
	('00000000-0000-0000-0000-000000000000', '4c412327-a9f9-4609-b013-9f1d98dd3a68', '{"action":"token_revoked","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 20:26:18.173643+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ed1edca3-12c2-42dd-b73c-c9d996fd23ea', '{"action":"logout","actor_id":"53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3","actor_username":"bb@bb.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 20:28:00.211911+00', ''),
	('00000000-0000-0000-0000-000000000000', '1882e87d-54da-4ca5-8d1e-93b3fd4b109f', '{"action":"user_signedup","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-08-20 20:28:20.192936+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f2b8e639-a5d2-4222-8d6a-38dd0b8edfc6', '{"action":"login","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 20:28:20.200769+00', ''),
	('00000000-0000-0000-0000-000000000000', '7aa56928-439a-4252-8049-1871c5dde752', '{"action":"logout","actor_id":"53b52c67-3224-4570-883c-ac36fe180b66","actor_username":"cc@cc.com","actor_via_sso":false,"log_type":"account"}', '2025-08-20 20:28:54.808338+00', ''),
	('00000000-0000-0000-0000-000000000000', '816edaf1-6dbf-4bb5-92d8-4fb462c29e58', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 20:29:07.748419+00', ''),
	('00000000-0000-0000-0000-000000000000', '4a974cdf-25f5-41b6-9460-349af3efa952', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 21:27:49.799256+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd9c5ea41-0fa3-4605-a732-52a50ebe62b4', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 21:27:49.81262+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd43c61aa-7efb-4818-b42c-0f19959a6e1a', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 21:28:30.33053+00', ''),
	('00000000-0000-0000-0000-000000000000', '19515592-5080-4e8a-9253-e36d61a5f5ba', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 21:28:30.332061+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c51bb577-ffcd-4788-9364-aa230f14daec', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 22:05:54.768709+00', ''),
	('00000000-0000-0000-0000-000000000000', '3c7d0f0e-c858-4f14-a7b5-f1b4b9a8ea68', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 22:27:21.04886+00', ''),
	('00000000-0000-0000-0000-000000000000', '652c07a1-1e59-457d-b0b6-2e83bd41bbcf', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 22:27:21.061295+00', ''),
	('00000000-0000-0000-0000-000000000000', 'eda5178f-8b9d-49f6-9145-1a9f38c15fa6', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 23:05:17.148664+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ebeb3d8e-56ba-422b-8da6-8f248cc1548d', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 23:05:17.174788+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b6a14472-eb09-4ee8-bf75-b5b0c91ddc96', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-20 23:33:44.809197+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bfc73889-cd61-429d-8fd1-77cc0eac31d8', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 23:36:10.915274+00', ''),
	('00000000-0000-0000-0000-000000000000', '157a3b8b-33cb-49fa-bf12-3e46793cd8bc', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-20 23:36:10.919818+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ad42517f-abcf-4d4b-8d49-8aade11300f9', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 03:59:42.445592+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a70c5f1b-e158-4708-8bd1-754a90bf4158', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 03:59:42.474649+00', ''),
	('00000000-0000-0000-0000-000000000000', '4103b5ba-a557-48ee-9b46-7fdff0eff102', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 05:20:50.547937+00', ''),
	('00000000-0000-0000-0000-000000000000', '746e112b-3aa4-48d6-88b0-332ca9221633', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 05:20:50.575541+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a94021a3-3f92-494c-8ae1-856a99e33236', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 09:06:08.621898+00', ''),
	('00000000-0000-0000-0000-000000000000', '9eb2ad98-a882-4cc9-b888-5e0ea6e7057b', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 09:06:08.655822+00', ''),
	('00000000-0000-0000-0000-000000000000', '6f541408-ceed-4fc4-b658-362120e52b69', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 10:05:33.217237+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a20ec5cb-f6df-437c-a7a3-68e4acae9467', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 10:05:33.23826+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a2b8f997-d5f8-4bc0-b5fc-7b771d46e57d', '{"action":"token_refreshed","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 11:05:02.97461+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ce38fd4a-f56a-4de8-be21-c96eab73c6b2', '{"action":"token_revoked","actor_id":"a02687a3-3ef8-4389-acc7-5d05e8d24537","actor_username":"gruto@naver.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 11:05:02.99779+00', ''),
	('00000000-0000-0000-0000-000000000000', '15ea00ce-34eb-4a68-9f1c-f8ce4c19f97e', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 09:33:11.925959+00', ''),
	('00000000-0000-0000-0000-000000000000', '964c0d13-110d-4227-b43d-f7e5b9cef4aa', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:04:28.677191+00', ''),
	('00000000-0000-0000-0000-000000000000', '97016765-9617-42c0-8c0c-5c87931559e1', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:04:38.443894+00', ''),
	('00000000-0000-0000-0000-000000000000', '6599e03b-8e9d-4e4e-8b1e-c626551da674', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:13:21.550238+00', ''),
	('00000000-0000-0000-0000-000000000000', '8bbfc5ac-3cde-4c25-906c-060209ae4269', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:13:27.957096+00', ''),
	('00000000-0000-0000-0000-000000000000', '190f4d5e-2689-45ba-8114-fc5d2aa89e04', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:17:01.623884+00', ''),
	('00000000-0000-0000-0000-000000000000', '759ff761-d563-4855-9402-77495faa2fd6', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:27:30.777524+00', ''),
	('00000000-0000-0000-0000-000000000000', '04022cf5-b013-416f-8852-fc8e022ee23b', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:30:38.146849+00', ''),
	('00000000-0000-0000-0000-000000000000', '360807ca-ac9e-448b-95ee-d203661eb2dc', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-23 23:32:43.109154+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bdffa8a7-2160-4f4e-9398-0cd697c8108c', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:34:47.64039+00', ''),
	('00000000-0000-0000-0000-000000000000', '23f2b2f9-af65-4818-ade4-55356f455dce', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-23 23:40:58.590896+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e0ca8392-7485-44a6-ad91-0ad69de3b236', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-23 23:41:09.158481+00', ''),
	('00000000-0000-0000-0000-000000000000', '533b10fb-86d5-4083-a46d-05fdc32a0a17', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-24 00:21:38.672315+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b07955a1-e125-4f45-b1a9-d619b5ad8daa', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-24 00:21:53.177183+00', ''),
	('00000000-0000-0000-0000-000000000000', '024bc622-788e-4bac-9122-7dd4f744ddab', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 01:21:16.274047+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ec4b9a16-28d1-4029-a47b-8bc287c6acca', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 01:21:16.295144+00', ''),
	('00000000-0000-0000-0000-000000000000', '9a386942-6c8b-4887-b1f1-216b1c35ebe8', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-24 01:54:09.904343+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b09bbe1a-1e8a-4872-a257-af2d82e0b2ab', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 02:20:45.797261+00', ''),
	('00000000-0000-0000-0000-000000000000', 'de3692be-0ac4-4ad0-aaa2-e5c3dfb9cfc3', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 02:20:45.80779+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dbb8208d-7e1e-4bbf-bf02-b507e39cd65e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 02:20:45.892367+00', ''),
	('00000000-0000-0000-0000-000000000000', '4084ce25-e0a1-495a-8b7a-24de31836526', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-24 02:27:19.733208+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b3050160-ba17-421f-8b13-944731103f78', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-24 02:45:26.374604+00', ''),
	('00000000-0000-0000-0000-000000000000', '1dd1690b-8d85-4a6b-9989-1905f80a060a', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 03:20:14.520442+00', ''),
	('00000000-0000-0000-0000-000000000000', '56ad54d1-d64d-435a-b6fb-510432795bb7', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 03:20:14.542895+00', ''),
	('00000000-0000-0000-0000-000000000000', '9c004202-7770-4ed3-8fec-3bbbbf1f3600', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 03:44:55.851517+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ed52e631-b753-4241-afbd-668af9df488e', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 03:44:55.862231+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c0423ab1-8080-4d35-a8e5-2af788d913a1', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-24 04:12:41.023587+00', ''),
	('00000000-0000-0000-0000-000000000000', '9a6255fa-cfb6-4014-a958-2e39f40e74b0', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 04:19:44.396009+00', ''),
	('00000000-0000-0000-0000-000000000000', '3aeae7d1-e3f6-4391-bf9e-02fb54c52180', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 04:19:44.403683+00', ''),
	('00000000-0000-0000-0000-000000000000', '41aa8369-8410-44f5-8d9c-84eb2fc7470d', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 04:19:44.457034+00', ''),
	('00000000-0000-0000-0000-000000000000', '1055b1f7-0320-4c0a-97eb-14a66d012b72', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 04:44:23.296957+00', ''),
	('00000000-0000-0000-0000-000000000000', '75b69bd7-7450-4ba2-a75b-87b4feb755c5', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 04:44:23.305775+00', ''),
	('00000000-0000-0000-0000-000000000000', '093a21d7-7077-4db3-9b05-92420181620e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 05:12:11.252442+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ce21e0dc-0f06-438a-9d4d-344ae80a025b', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 05:12:11.274958+00', ''),
	('00000000-0000-0000-0000-000000000000', '410b7ef0-1499-4044-8871-8c5d71e32324', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 05:19:14.478137+00', ''),
	('00000000-0000-0000-0000-000000000000', '72d776dd-7cd5-4ceb-8349-d530b5e2a57d', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 05:19:14.483507+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ffb1d117-4f9d-4cd5-a858-d01ccc9992e6', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 05:19:14.516342+00', ''),
	('00000000-0000-0000-0000-000000000000', '82597f16-3f4b-4982-a352-2659a17591ef', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 05:43:53.609927+00', ''),
	('00000000-0000-0000-0000-000000000000', '16213a90-098a-475d-99ff-e53f1040a16e', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 05:43:53.624942+00', ''),
	('00000000-0000-0000-0000-000000000000', '1b6a9dbc-9ae2-43c6-8865-7a1c232b2803', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 06:11:41.43306+00', ''),
	('00000000-0000-0000-0000-000000000000', '4004e03f-8c24-4ae9-a12a-32ec5ae5767b', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 06:11:41.445836+00', ''),
	('00000000-0000-0000-0000-000000000000', '23ff17d6-a418-483e-b165-bbb4af04a609', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 06:18:44.493211+00', ''),
	('00000000-0000-0000-0000-000000000000', '360f16d9-467d-4587-8dd8-efe7a36337d3', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 06:18:44.496377+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a4e84a92-4a42-4442-816a-a43afe02911b', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 06:18:44.52494+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e76c5c46-9a07-4efb-87c8-a751fbbf1713', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 06:43:23.561314+00', ''),
	('00000000-0000-0000-0000-000000000000', '0ffb08ac-de26-471c-b5ce-1f6992f2677a', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 06:43:23.570408+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e39a5d7a-6590-45e6-868e-f9d513485429', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 07:11:11.536766+00', ''),
	('00000000-0000-0000-0000-000000000000', '489d32bd-f8b8-4bd9-a7cf-8d496bfe1357', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 07:11:11.547729+00', ''),
	('00000000-0000-0000-0000-000000000000', '47c77f4a-a39a-49a9-9a2f-7d8dcbfc8fc5', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 07:18:14.662387+00', ''),
	('00000000-0000-0000-0000-000000000000', '3a33a1ad-0bfd-45ae-963f-2b2bf686eb5d', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 07:18:14.664453+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e2f4561a-e37a-4db4-b63c-407115fcc3cd', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 07:18:14.689519+00', ''),
	('00000000-0000-0000-0000-000000000000', '1d475773-b3fa-4d98-9177-0db9ee1779d8', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 07:42:53.420756+00', ''),
	('00000000-0000-0000-0000-000000000000', '21656795-a1d3-4002-8905-a38f4d40f84e', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 07:42:53.429058+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ef33de12-ce84-43cf-9b84-d402cf9d1192', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 08:10:41.452401+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd7cb797a-15c9-4005-bdf2-d2f2370b35c5', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 08:10:41.464229+00', ''),
	('00000000-0000-0000-0000-000000000000', '3a48cfb6-3044-4d14-932d-dab494c24364', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 08:17:44.749599+00', ''),
	('00000000-0000-0000-0000-000000000000', '72d73529-7d58-47e6-ab08-2294ee542979', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 08:17:44.752321+00', ''),
	('00000000-0000-0000-0000-000000000000', '5e130ea7-7b87-4efc-83d2-76e8234e1f0e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 08:17:44.785332+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f85460fc-e753-4a37-94f1-5365d47c6cf6', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 08:42:23.561825+00', ''),
	('00000000-0000-0000-0000-000000000000', '8f696e87-bda6-4ca4-ba59-9837b128bd2d', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 08:42:23.573962+00', ''),
	('00000000-0000-0000-0000-000000000000', '4f3ed810-3c3a-4730-8240-dc58c80c8a7e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 09:10:10.530093+00', ''),
	('00000000-0000-0000-0000-000000000000', '17b498f3-b8d7-41da-a623-05845054c877', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 09:10:10.546015+00', ''),
	('00000000-0000-0000-0000-000000000000', '4e1aab1e-a10e-489f-8d90-3788a02decb3', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 09:17:14.950442+00', ''),
	('00000000-0000-0000-0000-000000000000', '07880eb1-4088-4bf3-8ab2-c006ec33b26a', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 09:17:14.958658+00', ''),
	('00000000-0000-0000-0000-000000000000', '2c6f7bdb-f686-4f63-a85a-8fd9a44a58b6', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 09:17:15.011555+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bd96d54b-c8cc-428e-8de4-24ac13a8ff21', '{"action":"logout","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account"}', '2025-08-24 09:22:18.892871+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f31be8a0-1e8d-42e9-adc3-5d0ea69f4a4f', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 10:16:45.073262+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a38ac035-a2b2-44fd-b188-cd1cd4185d94', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 10:16:45.094482+00', ''),
	('00000000-0000-0000-0000-000000000000', '51bcc0e7-8616-4522-a8e7-b99657d96a99', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 10:16:45.150028+00', ''),
	('00000000-0000-0000-0000-000000000000', '9df04e69-1020-4875-bb62-e5987fc60398', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 11:16:15.211144+00', ''),
	('00000000-0000-0000-0000-000000000000', '89bd1ee2-a546-4f8f-9080-a756acbc3d6a', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 11:16:15.216702+00', ''),
	('00000000-0000-0000-0000-000000000000', '195def3a-0d5e-4671-9e9b-bb8604c7d20a', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 11:16:15.266307+00', ''),
	('00000000-0000-0000-0000-000000000000', '7c3626db-a980-4780-998a-34048fa54d93', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 12:15:45.508234+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e509f989-f21f-476a-8905-38a14d9c620a', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 12:15:45.527564+00', ''),
	('00000000-0000-0000-0000-000000000000', 'aa6118ed-26ca-4eca-8693-ba707001d92b', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 12:15:45.582049+00', ''),
	('00000000-0000-0000-0000-000000000000', '4822ad6c-b6cb-4749-83ed-508a85d22a57', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-24 12:20:11.533463+00', ''),
	('00000000-0000-0000-0000-000000000000', '940308ce-8404-409b-b306-2db85a66eaaf', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 13:15:15.628421+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e0b0d57b-2757-4d01-bdad-228ddef59de0', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 13:15:15.642284+00', ''),
	('00000000-0000-0000-0000-000000000000', '560985fa-faa7-4732-bdc9-677315091d79', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 13:15:15.684788+00', ''),
	('00000000-0000-0000-0000-000000000000', '000beec4-78c0-4c59-afd3-6e1c02f68891', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 13:19:34.378005+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd06c35f3-8513-4546-83de-bac26cd29e88', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 13:19:34.379524+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c757224d-a8fd-4f35-8c5d-7d3416754bc3', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 14:14:45.768837+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c3644fc4-665f-4793-b23b-c51c4011705b', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 14:14:45.785094+00', ''),
	('00000000-0000-0000-0000-000000000000', 'aa14a673-5faa-42a9-89ae-726f1fa58337', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 14:14:45.852955+00', ''),
	('00000000-0000-0000-0000-000000000000', '88d66eb1-1fc2-4a23-95d8-d3ad91a75f43', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 14:19:02.31918+00', ''),
	('00000000-0000-0000-0000-000000000000', '1f77b010-11eb-4e56-b0ad-8c1362d70341', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-24 14:19:02.322284+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f46c37bd-fdad-43fe-93e9-a6b1b50c4b70', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-25 00:38:27.585235+00', ''),
	('00000000-0000-0000-0000-000000000000', '96bc580e-c755-4a77-9a13-c8da652b645b', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-25 00:38:27.608586+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e153d82d-1317-40f1-8f21-d4b1c9c4f395', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-25 00:38:27.675265+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a75d60be-af7b-4d38-aeac-91ba0569a9f6', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-26 12:24:55.89888+00', ''),
	('00000000-0000-0000-0000-000000000000', '01a1ca69-3b4a-469c-b25f-bef08aa6fe59', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 13:24:22.624972+00', ''),
	('00000000-0000-0000-0000-000000000000', 'cb30e398-5a90-45fe-822e-4c1b9e94ce1e', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 13:24:22.649062+00', ''),
	('00000000-0000-0000-0000-000000000000', '3bed6b77-1379-44bc-b440-9f9d16a42186', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-26 14:21:14.166392+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e8c4d99d-304d-404c-abf1-24af21c91ec7', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 14:23:45.756118+00', ''),
	('00000000-0000-0000-0000-000000000000', '927d312a-3f6a-46ea-bffa-36bd7bae25dc', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 14:23:45.770876+00', ''),
	('00000000-0000-0000-0000-000000000000', '2e3475a8-bc99-47b6-b820-8e3578d866bb', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-26 14:54:40.265973+00', ''),
	('00000000-0000-0000-0000-000000000000', '3df2af0b-b66b-48eb-a2dc-4cf6ab2e7ea9', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 15:54:06.661602+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd95e316c-b2fe-4214-95bf-b38a12151720', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 15:54:06.667685+00', ''),
	('00000000-0000-0000-0000-000000000000', '1cbdebc7-0354-4b15-8dc4-2d4fc0a9e180', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 16:53:31.782479+00', ''),
	('00000000-0000-0000-0000-000000000000', '504e68b8-d390-4456-855b-e651d89f339f', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 16:53:31.807177+00', ''),
	('00000000-0000-0000-0000-000000000000', '7ee5ee24-9160-4aa3-a484-ae4144d57a92', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 17:52:57.340802+00', ''),
	('00000000-0000-0000-0000-000000000000', '82ae97c2-c46f-4904-840d-0942586963ab', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 17:52:57.35423+00', ''),
	('00000000-0000-0000-0000-000000000000', '6c718c9f-7486-4890-b7f9-25bfcde3bb90', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 18:52:22.000749+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dffd24b2-d3e7-4abd-bb2d-30153b4c8372', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-26 18:52:22.014708+00', ''),
	('00000000-0000-0000-0000-000000000000', '8998c54a-467d-4037-87e8-d18088cba16c', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-27 04:06:46.488782+00', ''),
	('00000000-0000-0000-0000-000000000000', '022f6f1b-5dd7-4a2d-8a4b-3e7a78fe31a5', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-27 08:55:39.110595+00', ''),
	('00000000-0000-0000-0000-000000000000', '80dfa2de-e9bc-463d-92bc-3b2ca1389a3e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 09:55:01.728403+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a69d1d0a-9faf-48db-9f65-074f920d56c1', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 09:55:01.743674+00', ''),
	('00000000-0000-0000-0000-000000000000', '6c69cfb3-34c5-472f-af3a-3625539df15e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 10:54:30.587231+00', ''),
	('00000000-0000-0000-0000-000000000000', '77612817-bd9e-4840-8871-349b35caad06', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 10:54:30.607078+00', ''),
	('00000000-0000-0000-0000-000000000000', '668189ac-cf91-4f3d-8496-b5b94e2c4794', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 11:53:52.422012+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd06927a4-a8f6-4a1c-b9e5-4b3e5075212e', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 11:53:52.43241+00', ''),
	('00000000-0000-0000-0000-000000000000', '88ae4ca0-3f92-4c75-9a5e-4caf61ca2c6a', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-27 12:22:41.673554+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ff853789-c636-4a78-a6a5-fd19ba0af0f1', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 13:22:02.92974+00', ''),
	('00000000-0000-0000-0000-000000000000', '03eeb07e-83cf-4c1d-9749-ab39b5068296', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 13:22:02.947904+00', ''),
	('00000000-0000-0000-0000-000000000000', '980aa4c1-103c-44b0-96eb-5f723cb82038', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 14:21:28.984923+00', ''),
	('00000000-0000-0000-0000-000000000000', '92e5032e-78d4-4e3e-a20a-3d9d96fb18c2', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 14:21:29.003817+00', ''),
	('00000000-0000-0000-0000-000000000000', '9a048c8f-3597-4540-9c3a-b4fc1757dd94', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-27 14:24:42.063055+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fc82d893-f09f-4001-a964-642515d78439', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-27 15:40:13.991234+00', ''),
	('00000000-0000-0000-0000-000000000000', 'aaa25347-1235-41d2-94bd-f8be0a2c82a8', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 16:39:39.910426+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd5e83ad4-474a-4887-9363-d202f8af0df3', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 16:39:39.935251+00', ''),
	('00000000-0000-0000-0000-000000000000', '2b9b209d-4eaa-44a6-9981-1e96df554b0f', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 17:39:05.616824+00', ''),
	('00000000-0000-0000-0000-000000000000', '6b1a057a-4b1c-43d5-9b4e-e03151654108', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 17:39:05.636918+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bb862de5-a983-41df-91d2-1e941e2fd19d', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 18:38:29.995869+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a57fd4e6-e6d7-4492-985f-766aa5056914', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 18:38:30.018781+00', ''),
	('00000000-0000-0000-0000-000000000000', '302e9435-6d32-48b1-af7a-7c391ec03849', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 19:37:55.734578+00', ''),
	('00000000-0000-0000-0000-000000000000', '31f7f7a8-a21b-45f4-a02c-8a8b8f447a10', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 19:37:55.750519+00', ''),
	('00000000-0000-0000-0000-000000000000', '3bfb1be9-b12b-4cc6-8197-3f92675518a5', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-27 19:50:36.259469+00', ''),
	('00000000-0000-0000-0000-000000000000', '7de1f80f-a7d5-42a4-8c98-e79d93b982c8', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 20:37:23.962948+00', ''),
	('00000000-0000-0000-0000-000000000000', '845220c7-b384-4176-ba9e-6ce576f28fe5', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 20:37:23.978547+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b3c98a3a-ee07-47b1-bd7b-be2ecd0b1aef', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-27 20:46:09.027555+00', ''),
	('00000000-0000-0000-0000-000000000000', '7b0402f9-3cb2-44a5-bab1-1938129a487d', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 20:50:55.896468+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ef210fbe-0cb1-456d-b1db-3c7044ac70bd', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 20:50:55.899044+00', ''),
	('00000000-0000-0000-0000-000000000000', '1e4c7762-e537-464b-9cf6-a2696c8e83a1', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 23:55:05.437196+00', ''),
	('00000000-0000-0000-0000-000000000000', '2ef79383-ab9f-4658-ba0a-c7da4e2f8d63', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-27 23:55:05.457376+00', ''),
	('00000000-0000-0000-0000-000000000000', '2bab6e36-aae8-4d8e-9e7e-e4ceb0757d90', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-28 04:44:55.68264+00', ''),
	('00000000-0000-0000-0000-000000000000', '46ad014c-0906-47b7-8ad9-958b6790005e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-28 05:43:53.698597+00', ''),
	('00000000-0000-0000-0000-000000000000', '8cf5349a-2369-48e6-81b3-fc849b9aa485', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-28 05:43:53.719633+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e39be600-ac0e-4977-8466-254d787c4f8d', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-28 15:52:05.892607+00', ''),
	('00000000-0000-0000-0000-000000000000', '9f6aac98-8de0-46e5-8ba7-ab67b4a6efee', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-28 22:16:20.017686+00', ''),
	('00000000-0000-0000-0000-000000000000', '52aea651-f35b-4386-9097-0a4e74e31d4d', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-28 23:32:23.187932+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ce3c6e6b-3665-4311-aac0-b76dce29720a', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-28 23:49:57.821668+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e8b9576e-ec3c-4d84-9da2-fcca085f06aa', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 00:49:24.00046+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a8e446ee-8211-4d00-8295-f298ddb355a0', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 00:49:24.01105+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f8a42b53-970c-472d-8ebb-135b8f6204bd', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 01:48:46.445365+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a2dc7580-9201-44dc-ac46-5bb85e0f5c6a', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 01:48:46.470549+00', ''),
	('00000000-0000-0000-0000-000000000000', '0d23d7b1-6c8f-4724-87fc-fa87d904cd0b', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 06:00:49.200389+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fa59831e-1dd2-40bc-82e9-b04bf17c9f3d', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 06:00:49.209468+00', ''),
	('00000000-0000-0000-0000-000000000000', '05cb0569-66fe-4698-8b40-ed245c39587e', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 09:54:59.590554+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a5834366-3457-49e1-82f7-62ac55685567', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 09:54:59.617997+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fa954a78-7396-4ec8-ac9f-dade5b75d37f', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 10:02:06.97967+00', ''),
	('00000000-0000-0000-0000-000000000000', '3117dc0d-afd7-4c3b-a3b0-1f8429672f1b', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 10:02:06.981913+00', ''),
	('00000000-0000-0000-0000-000000000000', '60a35668-1edb-4146-ac19-22dd25a4ca42', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 10:02:07.006309+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd256244b-74c9-4336-bef0-9512face33a5', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 10:02:07.017164+00', ''),
	('00000000-0000-0000-0000-000000000000', '62271205-8562-4f7e-848c-f57f66b6ed61', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 10:02:07.031308+00', ''),
	('00000000-0000-0000-0000-000000000000', '59f0c1d0-be35-4e07-8ae5-2f317f575910', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-29 11:52:46.606551+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b518bc9c-d5a6-478c-ad86-97ea8898bae7', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 12:52:09.98454+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f4b0d0d2-aba3-4b51-b30c-4b53d2527c9d', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-29 12:52:10.006553+00', ''),
	('00000000-0000-0000-0000-000000000000', '5b3d229c-1b0e-450d-a9b2-c469b5c3e2eb', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-29 15:06:17.683154+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bec6caba-334b-49ec-bb20-2d505de430f2', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-30 02:15:57.670069+00', ''),
	('00000000-0000-0000-0000-000000000000', '3cda4434-47be-4b0c-bbd9-8802ab38f212', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 03:15:23.17047+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b707d227-e828-4989-b09d-d9576d88516c', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 03:15:23.189771+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c19810c9-3783-48e3-8892-998e7d8ff4ca', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 03:31:12.081079+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c9ed582f-718e-4b89-a731-61d47bff920e', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 03:31:12.091012+00', ''),
	('00000000-0000-0000-0000-000000000000', '853d3733-55d3-49fc-83c6-962f0a6ea1fc', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 04:14:53.067613+00', ''),
	('00000000-0000-0000-0000-000000000000', '243c02b9-06b0-48e2-8900-22d103ca31ff', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 04:14:53.091469+00', ''),
	('00000000-0000-0000-0000-000000000000', '216365b9-d072-42e0-a146-f1f8044b13f2', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 04:30:39.238868+00', ''),
	('00000000-0000-0000-0000-000000000000', '915d7efa-4332-454a-9782-26964245f538', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 04:30:39.248649+00', ''),
	('00000000-0000-0000-0000-000000000000', '6a512dad-a62b-4071-8630-0fa1e6f79454', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 05:14:18.643599+00', ''),
	('00000000-0000-0000-0000-000000000000', '0328fd74-0b14-4b5a-8fb2-2d744f2a235c', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 05:14:18.655141+00', ''),
	('00000000-0000-0000-0000-000000000000', '7f3224b5-c3d8-4c97-9708-8d898cf00593', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 05:30:34.520697+00', ''),
	('00000000-0000-0000-0000-000000000000', '5913248f-47b6-472c-a060-d11612e0f167', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 05:30:34.529745+00', ''),
	('00000000-0000-0000-0000-000000000000', '394da1ea-e464-4660-8164-192d43504106', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 09:49:03.063951+00', ''),
	('00000000-0000-0000-0000-000000000000', '66cbe4f3-f75a-4c2a-83e0-f5f767a8b990', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 09:49:03.094744+00', ''),
	('00000000-0000-0000-0000-000000000000', '713d81bc-e574-4d30-9eb1-9f7203209ad5', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 09:53:08.730497+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dd7a759a-b52f-4480-9047-8e6cf5b5a445', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 09:53:08.739515+00', ''),
	('00000000-0000-0000-0000-000000000000', '69cf75a1-6e95-443a-beff-15b9e32f6dbd', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 10:49:18.05167+00', ''),
	('00000000-0000-0000-0000-000000000000', '075e9cf5-74fc-453b-9d08-52cc8a4b71a2', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 10:49:18.062554+00', ''),
	('00000000-0000-0000-0000-000000000000', '3b8964cc-63ef-48b7-bba9-a3aeb5f94772', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 10:52:39.384391+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c6648aa5-aa56-4648-9c58-5417d162e538', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 10:52:39.387861+00', ''),
	('00000000-0000-0000-0000-000000000000', '43457bd8-790b-4448-a518-040403d54c58', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 11:48:46.835159+00', ''),
	('00000000-0000-0000-0000-000000000000', 'da0c9af1-21fa-4bbe-9c3f-41b36b930556', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 11:48:46.857311+00', ''),
	('00000000-0000-0000-0000-000000000000', '6a1184bc-a0e7-45ba-987b-ad048dbe4f7c', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 11:52:06.660736+00', ''),
	('00000000-0000-0000-0000-000000000000', '75f6cc46-92b1-4341-86d3-e656be347aae', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 11:52:06.664311+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd4a1ac1a-e8de-40ff-8131-5958cc4d36b8', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 12:48:07.242273+00', ''),
	('00000000-0000-0000-0000-000000000000', '7d69f6d2-cdcb-49fd-bf2c-2d94949a3520', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 12:48:07.254951+00', ''),
	('00000000-0000-0000-0000-000000000000', '48b7a9df-1b1b-487b-9c92-d553495dd5e8', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 12:51:26.791419+00', ''),
	('00000000-0000-0000-0000-000000000000', '10c1ac2a-d436-4f39-9afc-7f1eb9574857', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 12:51:26.793792+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fd625390-4dd9-4997-808d-7484493d076d', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-30 13:31:14.008575+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bb25d8c0-cc82-4f10-ba93-d29099dba773', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 13:47:33.531567+00', ''),
	('00000000-0000-0000-0000-000000000000', '551e86f5-ff53-417b-8e8c-349c44d88c68', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 13:47:33.550183+00', ''),
	('00000000-0000-0000-0000-000000000000', '93d911c5-a65d-4060-8943-e4362cf84353', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 13:50:48.379377+00', ''),
	('00000000-0000-0000-0000-000000000000', '99b3a81d-543f-4f2e-baa8-cdc4fc16d183', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 13:50:48.38352+00', ''),
	('00000000-0000-0000-0000-000000000000', '07cfeeb3-78e5-4bf7-96fe-642eed6be769', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 14:46:58.582683+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f6996e17-88ca-4c56-9525-81a8b447b498', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 14:46:58.605928+00', ''),
	('00000000-0000-0000-0000-000000000000', '38380218-5d96-4419-b568-7f6d6cd2a258', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 14:50:13.672088+00', ''),
	('00000000-0000-0000-0000-000000000000', '05d6c4c6-5ffd-4772-9d50-1cda2e2c5192', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 14:50:13.674335+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ed7fa53c-e59f-47e4-9a30-062340077bbe', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-30 15:40:45.160383+00', ''),
	('00000000-0000-0000-0000-000000000000', '1606e480-8db6-42e2-ac51-a2367ec675cb', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 15:47:18.44297+00', ''),
	('00000000-0000-0000-0000-000000000000', '4db1d809-4e71-408a-a817-f61ff0b8460e', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 15:47:18.445838+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dcb145ef-f4de-42e8-bb5e-08338e92413e', '{"action":"login","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-30 16:23:40.933056+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd38d7a38-ba48-483a-80ce-3711d329efa4', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 16:46:40.649195+00', ''),
	('00000000-0000-0000-0000-000000000000', '52f59873-0905-407b-b2df-a7c3f9b42823', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 16:46:40.67135+00', ''),
	('00000000-0000-0000-0000-000000000000', 'be68e002-2af1-4c67-856d-e68b9d5dd66c', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 17:46:06.250525+00', ''),
	('00000000-0000-0000-0000-000000000000', '436ecc68-e501-46b8-ba51-08c1c2275620', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 17:46:06.274741+00', ''),
	('00000000-0000-0000-0000-000000000000', '26ef1275-dba1-4011-b3fd-a19c7f712349', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 18:45:34.550313+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e058e22b-5a9a-4ed8-9e53-80984616969d', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-30 18:45:34.5657+00', ''),
	('00000000-0000-0000-0000-000000000000', '167bde00-2ba4-4f9e-9c5c-c14deaaa003c', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 13:59:38.148021+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ce4d52c5-0820-4da3-9c8d-c57ce50fef37', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 13:59:38.168865+00', ''),
	('00000000-0000-0000-0000-000000000000', '18474a7a-49fd-42ca-88b1-4859388c6f49', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 14:59:09.079524+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a2d60db4-a4bb-4b4a-ade1-9d8d88bdd9c4', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 14:59:09.104386+00', ''),
	('00000000-0000-0000-0000-000000000000', 'caed6870-869a-409a-88c2-71853b588eaf', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 15:58:54.575624+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f854eb53-0345-4cd1-97d5-f9b4637789f4', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 15:58:54.597434+00', ''),
	('00000000-0000-0000-0000-000000000000', '7c867834-d9d0-48d6-83ce-ebe24d38e848', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 16:58:54.482133+00', ''),
	('00000000-0000-0000-0000-000000000000', '60af080a-5e92-4d38-befe-8d29f9bb4109', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 16:58:54.494468+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a9afa1b5-5dde-4e35-a718-1c9b849ea898', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 17:58:54.875571+00', ''),
	('00000000-0000-0000-0000-000000000000', '6d216ce6-76f7-4a87-bea5-3709ab009700', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 17:58:54.890874+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f1ed9e1a-07dc-43fc-83b8-ed018e2be720', '{"action":"token_refreshed","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 19:15:21.995393+00', ''),
	('00000000-0000-0000-0000-000000000000', '030ddecb-1cad-459d-814c-361bae7627ae', '{"action":"token_revoked","actor_id":"3c77d26b-f6f4-4a0a-b026-7b89faa9cb26","actor_username":"aa@aa.com","actor_via_sso":false,"log_type":"token"}', '2025-08-31 19:15:22.020414+00', '');


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at") VALUES
	('44d1a3cf-95b5-4f9e-91b6-61bef082e0e9', '53c6d884-ac92-47a6-8519-ecad9790fff6', '6d439ac3-f12b-497e-a72e-d8379c1a0897', 's256', 'n54zEeNiSt9GtJOlglHugxGR_s4Xw2D59ZPyGeL0Lj4', 'email', '', '', '2025-08-17 15:33:16.218158+00', '2025-08-17 15:33:16.218158+00', 'email/signup', NULL),
	('565df4a6-a92e-4fc2-8ccf-6271caee8741', '3622b3c6-3206-47cc-a3f9-bea14c52e0b9', 'acd4ee85-c71c-49ec-9911-82f20a0ccdae', 's256', 'BTB2qE8iFbGVhVaQ1nqCgI2qb3huuSAAIu7kbWI4EeU', 'email', '', '', '2025-08-19 16:17:40.669258+00', '2025-08-19 16:17:40.669258+00', 'email/signup', NULL),
	('c3585bdf-f478-4093-97d2-1f51952393df', '3622b3c6-3206-47cc-a3f9-bea14c52e0b9', '3370d5dd-53dc-450e-8c56-5d203505b3ef', 's256', 'mx8awN-9RW-WIh1OMJMPtginSKv1Or22g_u96TJwqpE', 'email', '', '', '2025-08-19 16:18:44.232644+00', '2025-08-19 16:18:44.232644+00', 'email/signup', NULL),
	('4e8bfa96-8d82-489f-8456-7ab14281e676', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', 'a52b4ea3-9e82-427d-842f-6e80594a8e4c', 's256', 'CBiWmJ8-LD3-ibuuibVIVooa3r5sk5qmp2tw0bUpzeQ', 'email', '', '', '2025-08-19 16:28:23.460657+00', '2025-08-19 16:28:23.460657+00', 'email/signup', NULL),
	('bc7b7f42-bd70-4cab-a17d-2f9f1f1c9695', 'f5e3c200-847f-4eaf-92fd-32ff479b67b9', '811c4172-c1d2-42d6-b758-ba53c825748a', 's256', 'c1rcaILBn9uX2Vb4rOSnZdOzARQ92rWjqXhQHZbZBZM', 'email', '', '', '2025-08-20 17:42:53.491057+00', '2025-08-20 17:42:53.491057+00', 'email/signup', NULL),
	('85682e83-83a9-427f-aa36-ab42e106d931', NULL, 'f338db1f-b68d-4c07-8489-db0cc134608d', 's256', 'a3C1JUlSFR0ATmtteq4vUQCzbMPiIo9sa9fPW7JcljY', 'google', '', '', '2025-08-24 09:39:13.072861+00', '2025-08-24 09:39:13.072861+00', 'oauth', NULL),
	('cbad3832-0491-4006-8b4e-703370165286', NULL, '83f12d9e-bd78-49d8-86d4-7d906b450d20', 's256', '7dC5dOY9tWLdnDWAg8hXBKVZrrwhyDeKvHF-e_pR3s8', 'kakao', '', '', '2025-08-24 10:31:17.849697+00', '2025-08-24 10:31:17.849697+00', 'oauth', NULL),
	('4e9b2420-9de2-40a2-a423-7b9c8ed7269b', NULL, '3ff7aeef-69ee-432f-92d8-d86a6f8bde09', 's256', '_ckS6rORFhM-kIpK2jz7U7kU4kTscwIlYurQiwuQ3t4', 'google', '', '', '2025-08-29 10:10:23.610138+00', '2025-08-29 10:10:23.610138+00', 'oauth', NULL);


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', 'authenticated', 'authenticated', 'ab@aa.com', '$2a$10$fTrbwd/AfDYaukie35KkeeaBD3Re7ACqWa6yucuDbOtXcObGPvr0q', '2025-08-19 16:57:33.276384+00', NULL, 'pkce_64ccafc4f952f2a607b18f4b3bb573c56e5fc35398e17f56c8df8ca1', '2025-08-19 16:28:23.464737+00', '', NULL, '', '', NULL, '2025-08-20 17:40:50.663991+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "fa8dbca3-ce25-4cb4-be55-e412c88dc203", "email": "ab@aa.com", "email_verified": false, "phone_verified": false}', NULL, '2025-08-19 16:28:23.435871+00', '2025-08-20 17:40:50.701407+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3', 'authenticated', 'authenticated', 'bb@bb.com', '$2a$10$u7ybp0OQ82wXK7X1CrCs2ennqPRJanJ2d81T1Gm6D2ml2Y14Gh53u', '2025-08-20 18:20:04.430575+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-08-20 18:20:04.434664+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3", "email": "bb@bb.com", "email_verified": true, "phone_verified": false}', NULL, '2025-08-20 18:20:04.42247+00', '2025-08-20 20:19:09.956209+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '53b52c67-3224-4570-883c-ac36fe180b66', 'authenticated', 'authenticated', 'cc@cc.com', '$2a$10$NXZmyrqPU.LzBQtxFBCy..3uL/qbqAPXjvvTIyqSOl3JQa7kFp4nm', '2025-08-20 18:16:13.095431+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-08-20 18:27:21.62549+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "53b52c67-3224-4570-883c-ac36fe180b66", "email": "cc@cc.com", "email_verified": true, "phone_verified": false}', NULL, '2025-08-20 18:16:13.062611+00', '2025-08-20 20:26:18.19271+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', 'authenticated', 'authenticated', 'gruto@naver.com', '$2a$10$iPoyYwXb8O29ZDX6DxEbF.HK5zrSEm5K1mpcW.684qEv2GkMvbQI6', '2025-08-20 20:28:20.193639+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-08-20 20:28:20.201619+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "a02687a3-3ef8-4389-acc7-5d05e8d24537", "email": "gruto@naver.com", "email_verified": true, "phone_verified": false}', NULL, '2025-08-20 20:28:20.162734+00', '2025-08-21 11:05:03.035711+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', 'authenticated', 'authenticated', 'aa@aa.com', '$2a$10$L/MhITml9QOfAP6tHh1H2uw0wbvhIUY4hJGNFA.gJ3xiT9fTDIpbW', '2025-08-19 16:47:55.552327+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-08-30 16:23:40.957586+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-08-19 16:47:55.514926+00', '2025-08-31 19:15:22.053033+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('fa8dbca3-ce25-4cb4-be55-e412c88dc203', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', '{"sub": "fa8dbca3-ce25-4cb4-be55-e412c88dc203", "email": "ab@aa.com", "email_verified": false, "phone_verified": false}', 'email', '2025-08-19 16:28:23.450873+00', '2025-08-19 16:28:23.450938+00', '2025-08-19 16:28:23.450938+00', '8a1fee3a-d986-4c87-a757-c62aa385b3ce'),
	('3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{"sub": "3c77d26b-f6f4-4a0a-b026-7b89faa9cb26", "email": "aa@aa.com", "email_verified": false, "phone_verified": false}', 'email', '2025-08-19 16:47:55.538159+00', '2025-08-19 16:47:55.538227+00', '2025-08-19 16:47:55.538227+00', '07972378-4408-46cd-ab8b-3be5bb254f3b'),
	('53b52c67-3224-4570-883c-ac36fe180b66', '53b52c67-3224-4570-883c-ac36fe180b66', '{"sub": "53b52c67-3224-4570-883c-ac36fe180b66", "email": "cc@cc.com", "email_verified": false, "phone_verified": false}', 'email', '2025-08-20 18:16:13.085343+00', '2025-08-20 18:16:13.086124+00', '2025-08-20 18:16:13.086124+00', 'd5c1774c-49c8-45c5-bef4-0b4ebca8cd41'),
	('53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3', '53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3', '{"sub": "53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3", "email": "bb@bb.com", "email_verified": false, "phone_verified": false}', 'email', '2025-08-20 18:20:04.42718+00', '2025-08-20 18:20:04.427229+00', '2025-08-20 18:20:04.427229+00', '1a165d11-bd7b-4f37-8ca4-051f6fd60eab'),
	('a02687a3-3ef8-4389-acc7-5d05e8d24537', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', '{"sub": "a02687a3-3ef8-4389-acc7-5d05e8d24537", "email": "gruto@naver.com", "email_verified": false, "phone_verified": false}', 'email', '2025-08-20 20:28:20.184014+00', '2025-08-20 20:28:20.18408+00', '2025-08-20 20:28:20.18408+00', '37045c5c-8817-4318-8d61-cf5547ce8a2b');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag") VALUES
	('31b9861d-6ab4-40bc-9057-f6fde2b637b6', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 10:04:37.918082+00', '2025-08-20 10:04:37.918082+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('69246465-3840-4970-9f53-127de1dcf58d', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 23:04:28.696336+00', '2025-08-23 23:04:28.696336+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('ebbf1e24-1015-4065-85b8-7adaaa86625f', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 02:59:29.834901+00', '2025-08-20 02:59:29.834901+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('9c69d379-c1b4-4f58-9597-7e165a92b87d', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 03:14:47.688294+00', '2025-08-20 03:14:47.688294+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('efe86726-ea45-41fd-94f9-e0787e46deae', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 03:26:24.34267+00', '2025-08-20 03:26:24.34267+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('423e7af8-a4b6-4883-920d-7fdb29ab36c8', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 04:11:54.662341+00', '2025-08-20 04:11:54.662341+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('a5cdfc2b-6591-4aa9-a844-aaaf0a3427b1', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 23:04:38.445307+00', '2025-08-23 23:04:38.445307+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('0e7fa560-edb7-4c49-92ac-f8090b460ce8', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 04:53:32.263861+00', '2025-08-20 04:53:32.263861+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('299d809d-c822-4aa0-9da8-c8bb1b7bc962', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 10:21:40.439493+00', '2025-08-20 12:20:38.292964+00', NULL, 'aal1', NULL, '2025-08-20 12:20:38.292869', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('b1174b2f-54a9-4cc0-a43e-5c654b0d1e3b', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', '2025-08-20 04:32:43.982207+00', '2025-08-20 09:03:50.493674+00', NULL, 'aal1', NULL, '2025-08-20 09:03:50.492955', 'Dart/3.8 (dart:io)', '112.152.75.37', NULL),
	('086bd9dd-a5fe-49be-8bf0-2502bdfce59a', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', '2025-08-20 10:27:59.565445+00', '2025-08-20 12:26:54.621174+00', NULL, 'aal1', NULL, '2025-08-20 12:26:54.621071', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('f7899191-8ee0-49a6-bd92-8c44648d7f72', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 23:13:21.560931+00', '2025-08-23 23:13:21.560931+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('f2c38ba4-ef72-4b29-a410-ce95932ba2ad', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 23:13:27.957984+00', '2025-08-23 23:13:27.957984+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('f5153dd9-d5b1-4c87-9c07-9ba61ac92c73', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 23:17:01.625027+00', '2025-08-23 23:17:01.625027+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('a735d6f6-3bb4-4683-bdac-b81bc77ff4f9', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 23:27:30.789639+00', '2025-08-23 23:27:30.789639+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('dc51c29e-6e41-40ac-a0d8-d690ef673499', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 20:29:07.749588+00', '2025-08-20 21:28:30.337431+00', NULL, 'aal1', NULL, '2025-08-20 21:28:30.337356', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('c068461f-ded2-4c6d-ac37-77b3ba9b7e6f', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 22:05:54.795614+00', '2025-08-20 23:05:17.217416+00', NULL, 'aal1', NULL, '2025-08-20 23:05:17.217328', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('5a72af7d-7cb6-4ff5-8d40-42d57514d64a', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-20 23:33:44.852503+00', '2025-08-20 23:33:44.852503+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-24 02:45:26.395324+00', '2025-08-24 08:42:23.597727+00', NULL, 'aal1', NULL, '2025-08-24 08:42:23.597635', 'Dart/3.8 (dart:io)', '112.152.75.37', NULL),
	('a8ba9368-15d8-412f-b21e-8dd863e0ba55', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', '2025-08-20 20:28:20.201719+00', '2025-08-21 11:05:03.045197+00', NULL, 'aal1', NULL, '2025-08-21 11:05:03.044471', 'Dart/3.8 (dart:io)', '112.152.75.37', NULL),
	('def8e404-2dd4-4c6f-a21d-31571a31ee10', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 09:33:11.944169+00', '2025-08-23 09:33:11.944169+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('f42374b5-3902-4acb-a585-834f62e196f4', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 12:22:41.697209+00', '2025-08-27 14:21:29.049931+00', NULL, 'aal1', NULL, '2025-08-27 14:21:29.048677', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('9fb4374a-a633-40bd-a646-fee354f3659a', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 14:24:42.075278+00', '2025-08-27 14:24:42.075278+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('c27d859a-051b-474d-bdcd-be66afac813e', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-26 14:54:40.28757+00', '2025-08-26 18:52:22.039351+00', NULL, 'aal1', NULL, '2025-08-26 18:52:22.038697', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('2dd580e3-2101-4775-ac99-9b24ac3357d6', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-24 12:20:11.538564+00', '2025-08-24 14:19:02.330054+00', NULL, 'aal1', NULL, '2025-08-24 14:19:02.329984', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('129375b0-87cc-41dd-825c-061caa0b8171', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-24 00:21:53.186918+00', '2025-08-25 00:38:27.680558+00', NULL, 'aal1', NULL, '2025-08-25 00:38:27.679064', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('230eeee9-4b97-4b03-a0c1-fd7f41b3f2f6', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-28 15:52:05.907304+00', '2025-08-28 15:52:05.907304+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('e81fb4c6-93a2-499f-9f44-0e592cf58802', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-26 14:21:14.18957+00', '2025-08-26 14:21:14.18957+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('a4738d6d-d200-4836-a9b4-9560e18553ea', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-26 12:24:55.918181+00', '2025-08-26 14:23:45.80002+00', NULL, 'aal1', NULL, '2025-08-26 14:23:45.798746', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('fdba6f84-ad71-495a-817a-ac732530ae3e', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 08:55:39.142188+00', '2025-08-27 11:53:52.456044+00', NULL, 'aal1', NULL, '2025-08-27 11:53:52.45476', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('9913afa5-63f0-4de2-a135-2665e13ec39d', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 15:40:14.01062+00', '2025-08-27 20:37:24.028902+00', NULL, 'aal1', NULL, '2025-08-27 20:37:24.028809', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('ec7f35ea-83c2-42ab-a9f7-165a6178e925', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 20:46:09.032582+00', '2025-08-27 20:46:09.032582+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('4f481247-2a34-4383-8c0b-d590f8a1eda4', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-28 22:16:20.050118+00', '2025-08-28 22:16:20.050118+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('a2273ea1-6c30-420b-97a8-800c393801cb', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-28 23:32:23.214442+00', '2025-08-28 23:32:23.214442+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('de28c3ba-516c-4f22-82a5-22b1aa41d1be', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-28 04:44:55.711149+00', '2025-08-29 09:54:59.67165+00', NULL, 'aal1', NULL, '2025-08-29 09:54:59.67027', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36', '106.102.142.227', NULL),
	('dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 19:50:36.282672+00', '2025-08-31 19:15:22.064766+00', NULL, 'aal1', NULL, '2025-08-31 19:15:22.064685', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('07046f8c-cfd3-400f-8f89-96fe17a073de', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 04:06:46.520916+00', '2025-08-30 14:50:13.681945+00', NULL, 'aal1', NULL, '2025-08-30 14:50:13.680611', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('d974cb19-e60f-42ee-9970-ff129d7b9e98', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-28 23:49:57.831344+00', '2025-08-29 10:02:07.035082+00', NULL, 'aal1', NULL, '2025-08-29 10:02:07.034994', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('708c504d-5775-42c5-af06-947d11003056', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-29 11:52:46.619101+00', '2025-08-29 12:52:10.058687+00', NULL, 'aal1', NULL, '2025-08-29 12:52:10.058598', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('d52767a0-4246-448b-856b-a0173c401925', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-29 15:06:17.718941+00', '2025-08-29 15:06:17.718941+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('e16a76ed-04c6-4b27-a6b0-e99cdfbb4bd8', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-30 02:15:57.702214+00', '2025-08-30 05:14:18.682829+00', NULL, 'aal1', NULL, '2025-08-30 05:14:18.68273', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('a45f280b-8338-4db6-8402-7e3d177305a4', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-30 13:31:14.026132+00', '2025-08-30 13:31:14.026132+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('d425b9aa-54dc-40b9-881d-03ddce1e95c4', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-30 15:40:45.186838+00', '2025-08-30 15:40:45.186838+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL),
	('d6d256b0-c34a-4f84-917b-135c64e44e79', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-30 16:23:40.958348+00', '2025-08-30 16:23:40.958348+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '112.152.75.37', NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('ebbf1e24-1015-4065-85b8-7adaaa86625f', '2025-08-20 02:59:29.861693+00', '2025-08-20 02:59:29.861693+00', 'password', 'a83db54e-ce05-41ac-b378-d8a684932d73'),
	('9c69d379-c1b4-4f58-9597-7e165a92b87d', '2025-08-20 03:14:47.722431+00', '2025-08-20 03:14:47.722431+00', 'password', '0e40a87b-8c75-4431-84a8-8193f45c3024'),
	('efe86726-ea45-41fd-94f9-e0787e46deae', '2025-08-20 03:26:24.373061+00', '2025-08-20 03:26:24.373061+00', 'password', '04379771-4ea7-40b8-b73e-5cd7cdcfaeb7'),
	('423e7af8-a4b6-4883-920d-7fdb29ab36c8', '2025-08-20 04:11:54.691718+00', '2025-08-20 04:11:54.691718+00', 'password', '40b00414-bef3-46be-a15d-1a52053c8c1d'),
	('b1174b2f-54a9-4cc0-a43e-5c654b0d1e3b', '2025-08-20 04:32:43.992889+00', '2025-08-20 04:32:43.992889+00', 'password', 'f78aecb4-4543-4e83-a442-84591d9fc321'),
	('0e7fa560-edb7-4c49-92ac-f8090b460ce8', '2025-08-20 04:53:32.325991+00', '2025-08-20 04:53:32.325991+00', 'password', '72437534-f7a5-465b-a9d4-2c8d9f727b65'),
	('31b9861d-6ab4-40bc-9057-f6fde2b637b6', '2025-08-20 10:04:37.937617+00', '2025-08-20 10:04:37.937617+00', 'password', 'a03059ed-e0c2-4790-8a30-14f7519fc0d6'),
	('299d809d-c822-4aa0-9da8-c8bb1b7bc962', '2025-08-20 10:21:40.455969+00', '2025-08-20 10:21:40.455969+00', 'password', '29ba2fe8-d293-4049-b11a-83dfb2fe2fde'),
	('086bd9dd-a5fe-49be-8bf0-2502bdfce59a', '2025-08-20 10:27:59.590231+00', '2025-08-20 10:27:59.590231+00', 'password', 'e63f10ea-ceb5-44b8-a58e-f1cd24dc5a84'),
	('a8ba9368-15d8-412f-b21e-8dd863e0ba55', '2025-08-20 20:28:20.214312+00', '2025-08-20 20:28:20.214312+00', 'password', '43f8b7f5-7ded-41eb-89f6-cfab369ccb53'),
	('dc51c29e-6e41-40ac-a0d8-d690ef673499', '2025-08-20 20:29:07.752461+00', '2025-08-20 20:29:07.752461+00', 'password', '4662f648-ec55-4dff-add3-247e163b9638'),
	('c068461f-ded2-4c6d-ac37-77b3ba9b7e6f', '2025-08-20 22:05:54.864309+00', '2025-08-20 22:05:54.864309+00', 'password', '5b06d6ee-c1a7-44eb-8143-7ba7294fdc0c'),
	('5a72af7d-7cb6-4ff5-8d40-42d57514d64a', '2025-08-20 23:33:44.908501+00', '2025-08-20 23:33:44.908501+00', 'password', '076ca389-255f-4286-8624-f24a812a032a'),
	('def8e404-2dd4-4c6f-a21d-31571a31ee10', '2025-08-23 09:33:12.021912+00', '2025-08-23 09:33:12.021912+00', 'password', '007f9fff-a4dd-4d9c-b61a-2b9c36002efd'),
	('69246465-3840-4970-9f53-127de1dcf58d', '2025-08-23 23:04:28.741046+00', '2025-08-23 23:04:28.741046+00', 'password', '89891a5a-fdfa-4d18-9c7e-e535aedaf92f'),
	('a5cdfc2b-6591-4aa9-a844-aaaf0a3427b1', '2025-08-23 23:04:38.448309+00', '2025-08-23 23:04:38.448309+00', 'password', '5c4eb179-4e75-4237-af22-4e1732e1dc5e'),
	('f7899191-8ee0-49a6-bd92-8c44648d7f72', '2025-08-23 23:13:21.601558+00', '2025-08-23 23:13:21.601558+00', 'password', '3fabcd07-68da-43ee-a537-d1519ddc9df4'),
	('f2c38ba4-ef72-4b29-a410-ce95932ba2ad', '2025-08-23 23:13:27.960625+00', '2025-08-23 23:13:27.960625+00', 'password', 'c08390f8-8717-4ae7-a663-0167bf03172d'),
	('f5153dd9-d5b1-4c87-9c07-9ba61ac92c73', '2025-08-23 23:17:01.628407+00', '2025-08-23 23:17:01.628407+00', 'password', 'a90b5073-147d-4dfd-b00e-56765c3eb30a'),
	('a735d6f6-3bb4-4683-bdac-b81bc77ff4f9', '2025-08-23 23:27:30.827968+00', '2025-08-23 23:27:30.827968+00', 'password', '3bb2b3c0-5de6-4b4a-b001-5594daa894c0'),
	('129375b0-87cc-41dd-825c-061caa0b8171', '2025-08-24 00:21:53.210857+00', '2025-08-24 00:21:53.210857+00', 'password', '3d70bda1-01f2-4e66-8442-a4ea56bb9c1f'),
	('5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b', '2025-08-24 02:45:26.447459+00', '2025-08-24 02:45:26.447459+00', 'password', '98257965-0245-4ebf-bfab-061b1bae26dc'),
	('2dd580e3-2101-4775-ac99-9b24ac3357d6', '2025-08-24 12:20:11.55377+00', '2025-08-24 12:20:11.55377+00', 'password', '1d3837af-04c8-4045-9f25-32e77802aa7c'),
	('a4738d6d-d200-4836-a9b4-9560e18553ea', '2025-08-26 12:24:55.964686+00', '2025-08-26 12:24:55.964686+00', 'password', '1f48a6f0-ee30-458c-9742-0d1bfe8d05a9'),
	('e81fb4c6-93a2-499f-9f44-0e592cf58802', '2025-08-26 14:21:14.252281+00', '2025-08-26 14:21:14.252281+00', 'password', '4c292e94-d226-484d-ae71-82520ef5a7d1'),
	('c27d859a-051b-474d-bdcd-be66afac813e', '2025-08-26 14:54:40.333262+00', '2025-08-26 14:54:40.333262+00', 'password', '5b25bcc8-5f8c-4ece-990e-ca3e68313964'),
	('07046f8c-cfd3-400f-8f89-96fe17a073de', '2025-08-27 04:06:46.585982+00', '2025-08-27 04:06:46.585982+00', 'password', '6daa1c16-00a0-434e-8643-b5d4463940ad'),
	('fdba6f84-ad71-495a-817a-ac732530ae3e', '2025-08-27 08:55:39.215834+00', '2025-08-27 08:55:39.215834+00', 'password', '2d1ad8bc-da2b-4830-b3e0-61aa6e1f904a'),
	('f42374b5-3902-4acb-a585-834f62e196f4', '2025-08-27 12:22:41.771984+00', '2025-08-27 12:22:41.771984+00', 'password', 'b02d404f-2dfb-4f9c-bc12-974532983088'),
	('9fb4374a-a633-40bd-a646-fee354f3659a', '2025-08-27 14:24:42.105858+00', '2025-08-27 14:24:42.105858+00', 'password', '1ae935ee-f245-43ca-a9b4-5ac56394addf'),
	('9913afa5-63f0-4de2-a135-2665e13ec39d', '2025-08-27 15:40:14.07229+00', '2025-08-27 15:40:14.07229+00', 'password', '21acf2b8-e861-40d6-9d61-21698153e75a'),
	('dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1', '2025-08-27 19:50:36.328154+00', '2025-08-27 19:50:36.328154+00', 'password', '995e7e45-16c7-48a1-bdc3-41790bb56875'),
	('ec7f35ea-83c2-42ab-a9f7-165a6178e925', '2025-08-27 20:46:09.043688+00', '2025-08-27 20:46:09.043688+00', 'password', 'bd6f2e58-0905-4ae5-897a-da7051af6eb5'),
	('de28c3ba-516c-4f22-82a5-22b1aa41d1be', '2025-08-28 04:44:55.78018+00', '2025-08-28 04:44:55.78018+00', 'password', '102057d3-609c-4224-b12c-213b9c58d3e0'),
	('230eeee9-4b97-4b03-a0c1-fd7f41b3f2f6', '2025-08-28 15:52:05.93369+00', '2025-08-28 15:52:05.93369+00', 'password', 'c937d39f-1fd1-482e-a818-7b66fc466c58'),
	('4f481247-2a34-4383-8c0b-d590f8a1eda4', '2025-08-28 22:16:20.13014+00', '2025-08-28 22:16:20.13014+00', 'password', 'fc99fcb4-ee31-43ba-ba5a-c4cc17e2a04d'),
	('a2273ea1-6c30-420b-97a8-800c393801cb', '2025-08-28 23:32:23.268321+00', '2025-08-28 23:32:23.268321+00', 'password', '62a309ea-ea0d-4061-99c6-ba8f42e0418d'),
	('d974cb19-e60f-42ee-9970-ff129d7b9e98', '2025-08-28 23:49:57.860682+00', '2025-08-28 23:49:57.860682+00', 'password', '93800fad-5d2a-4022-9d04-7917d560e1a9'),
	('708c504d-5775-42c5-af06-947d11003056', '2025-08-29 11:52:46.648935+00', '2025-08-29 11:52:46.648935+00', 'password', '09bb101f-541e-449e-b39f-9c598d0fd832'),
	('d52767a0-4246-448b-856b-a0173c401925', '2025-08-29 15:06:17.794364+00', '2025-08-29 15:06:17.794364+00', 'password', 'de9a35c8-27a4-495f-8467-15805a64bfe8'),
	('e16a76ed-04c6-4b27-a6b0-e99cdfbb4bd8', '2025-08-30 02:15:57.777014+00', '2025-08-30 02:15:57.777014+00', 'password', '5c0e6542-7dce-4d2c-a3b6-3bcb407dd241'),
	('a45f280b-8338-4db6-8402-7e3d177305a4', '2025-08-30 13:31:14.08588+00', '2025-08-30 13:31:14.08588+00', 'password', '8aef251e-4db3-4acc-863d-6a8d5a62228e'),
	('d425b9aa-54dc-40b9-881d-03ddce1e95c4', '2025-08-30 15:40:45.241023+00', '2025-08-30 15:40:45.241023+00', 'password', 'dd855b34-22e4-4ae9-a0e4-39b8c076fdaa'),
	('d6d256b0-c34a-4f84-917b-135c64e44e79', '2025-08-30 16:23:41.02816+00', '2025-08-30 16:23:41.02816+00', 'password', '4bb5557b-d238-4950-8162-eac39301d3b0');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."one_time_tokens" ("id", "user_id", "token_type", "token_hash", "relates_to", "created_at", "updated_at") VALUES
	('61a3b4e2-305a-4c7a-81b5-1e4327bfa7e8', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', 'confirmation_token', 'pkce_64ccafc4f952f2a607b18f4b3bb573c56e5fc35398e17f56c8df8ca1', 'ab@aa.com', '2025-08-19 16:28:25.171873', '2025-08-19 16:28:25.171873');


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 124, 'uz35xtdec2e7', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-26 17:52:57.364398+00', '2025-08-26 18:52:22.016151+00', 'o5o44sc4zq52', 'c27d859a-051b-474d-bdcd-be66afac813e'),
	('00000000-0000-0000-0000-000000000000', 128, 'azw4lifevdgt', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 09:55:01.751662+00', '2025-08-27 10:54:30.609078+00', 'kstgfc6nr2nj', 'fdba6f84-ad71-495a-817a-ac732530ae3e'),
	('00000000-0000-0000-0000-000000000000', 126, '7ckbqpkvldrb', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 04:06:46.542835+00', '2025-08-30 09:53:08.74015+00', NULL, '07046f8c-cfd3-400f-8f89-96fe17a073de'),
	('00000000-0000-0000-0000-000000000000', 60, 'a6cxl4nvmjpx', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-20 20:28:20.211563+00', '2025-08-20 21:27:49.814713+00', NULL, 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 61, 'skfhopz43xdz', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-20 20:29:07.751123+00', '2025-08-20 21:28:30.332713+00', NULL, 'dc51c29e-6e41-40ac-a0d8-d690ef673499'),
	('00000000-0000-0000-0000-000000000000', 63, 'ze3fn7uuuywv', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 21:28:30.333073+00', '2025-08-20 21:28:30.333073+00', 'skfhopz43xdz', 'dc51c29e-6e41-40ac-a0d8-d690ef673499'),
	('00000000-0000-0000-0000-000000000000', 62, '62hu52db4wz5', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-20 21:27:49.825219+00', '2025-08-20 22:27:21.062025+00', 'a6cxl4nvmjpx', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 64, 'hnvzxy47wezy', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-20 22:05:54.816948+00', '2025-08-20 23:05:17.178174+00', NULL, 'c068461f-ded2-4c6d-ac37-77b3ba9b7e6f'),
	('00000000-0000-0000-0000-000000000000', 66, 'su2e7sj5cucp', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 23:05:17.194798+00', '2025-08-20 23:05:17.194798+00', 'hnvzxy47wezy', 'c068461f-ded2-4c6d-ac37-77b3ba9b7e6f'),
	('00000000-0000-0000-0000-000000000000', 67, 'jlrhcnxpm5ie', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 23:33:44.874913+00', '2025-08-20 23:33:44.874913+00', NULL, '5a72af7d-7cb6-4ff5-8d40-42d57514d64a'),
	('00000000-0000-0000-0000-000000000000', 65, '7nfzth25feos', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-20 22:27:21.073992+00', '2025-08-20 23:36:10.921185+00', '62hu52db4wz5', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 68, '5ma74jyls53l', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-20 23:36:10.925875+00', '2025-08-21 03:59:42.476036+00', '7nfzth25feos', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 69, 'o6cq62dolovx', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-21 03:59:42.498152+00', '2025-08-21 05:20:50.57637+00', '5ma74jyls53l', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 70, '4kijqpc2kxio', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-21 05:20:50.602509+00', '2025-08-21 09:06:08.65752+00', 'o6cq62dolovx', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 71, 'o4go3jtiggv4', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-21 09:06:08.678162+00', '2025-08-21 10:05:33.242916+00', '4kijqpc2kxio', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 72, 'qctquumq557z', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', true, '2025-08-21 10:05:33.265365+00', '2025-08-21 11:05:02.999296+00', 'o4go3jtiggv4', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 73, 'x2q3nx6hpegz', 'a02687a3-3ef8-4389-acc7-5d05e8d24537', false, '2025-08-21 11:05:03.019824+00', '2025-08-21 11:05:03.019824+00', 'qctquumq557z', 'a8ba9368-15d8-412f-b21e-8dd863e0ba55'),
	('00000000-0000-0000-0000-000000000000', 74, 'n4qluzlder2r', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-23 09:33:11.969486+00', '2025-08-23 09:33:11.969486+00', NULL, 'def8e404-2dd4-4c6f-a21d-31571a31ee10'),
	('00000000-0000-0000-0000-000000000000', 75, 'p57qqnfbqgcw', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-23 23:04:28.714392+00', '2025-08-23 23:04:28.714392+00', NULL, '69246465-3840-4970-9f53-127de1dcf58d'),
	('00000000-0000-0000-0000-000000000000', 76, '5cp7piguvaph', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-23 23:04:38.447142+00', '2025-08-23 23:04:38.447142+00', NULL, 'a5cdfc2b-6591-4aa9-a844-aaaf0a3427b1'),
	('00000000-0000-0000-0000-000000000000', 32, 'ukctw2xskv36', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 02:59:29.848426+00', '2025-08-20 02:59:29.848426+00', NULL, 'ebbf1e24-1015-4065-85b8-7adaaa86625f'),
	('00000000-0000-0000-0000-000000000000', 33, 'cq4kx7xcksft', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 03:14:47.70263+00', '2025-08-20 03:14:47.70263+00', NULL, '9c69d379-c1b4-4f58-9597-7e165a92b87d'),
	('00000000-0000-0000-0000-000000000000', 34, 'qfy7sqtfd4ze', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 03:26:24.356416+00', '2025-08-20 03:26:24.356416+00', NULL, 'efe86726-ea45-41fd-94f9-e0787e46deae'),
	('00000000-0000-0000-0000-000000000000', 35, '5lqgm4nvlmnn', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 04:11:54.675748+00', '2025-08-20 04:11:54.675748+00', NULL, '423e7af8-a4b6-4883-920d-7fdb29ab36c8'),
	('00000000-0000-0000-0000-000000000000', 77, 'dmc4aprlkdqe', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-23 23:13:21.574682+00', '2025-08-23 23:13:21.574682+00', NULL, 'f7899191-8ee0-49a6-bd92-8c44648d7f72'),
	('00000000-0000-0000-0000-000000000000', 78, 'a3hbl4x6yx5m', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-23 23:13:27.958739+00', '2025-08-23 23:13:27.958739+00', NULL, 'f2c38ba4-ef72-4b29-a410-ce95932ba2ad'),
	('00000000-0000-0000-0000-000000000000', 79, 'x7jbcncp3g3v', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-23 23:17:01.626286+00', '2025-08-23 23:17:01.626286+00', NULL, 'f5153dd9-d5b1-4c87-9c07-9ba61ac92c73'),
	('00000000-0000-0000-0000-000000000000', 38, 'zpgjd3mhtc2n', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 04:53:32.289538+00', '2025-08-20 04:53:32.289538+00', NULL, '0e7fa560-edb7-4c49-92ac-f8090b460ce8'),
	('00000000-0000-0000-0000-000000000000', 37, 'pnnagsy7mylh', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', true, '2025-08-20 04:32:43.987517+00', '2025-08-20 08:04:25.834066+00', NULL, 'b1174b2f-54a9-4cc0-a43e-5c654b0d1e3b'),
	('00000000-0000-0000-0000-000000000000', 80, 'mj7yuunsl34y', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-23 23:27:30.808822+00', '2025-08-23 23:27:30.808822+00', NULL, 'a735d6f6-3bb4-4683-bdac-b81bc77ff4f9'),
	('00000000-0000-0000-0000-000000000000', 39, '7hugelczflxv', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', true, '2025-08-20 08:04:25.855347+00', '2025-08-20 09:03:50.456233+00', 'pnnagsy7mylh', 'b1174b2f-54a9-4cc0-a43e-5c654b0d1e3b'),
	('00000000-0000-0000-0000-000000000000', 40, '7pbkzu5mbjzk', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', false, '2025-08-20 09:03:50.470803+00', '2025-08-20 09:03:50.470803+00', '7hugelczflxv', 'b1174b2f-54a9-4cc0-a43e-5c654b0d1e3b'),
	('00000000-0000-0000-0000-000000000000', 45, 'izq3abanb2mh', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 10:04:37.922834+00', '2025-08-20 10:04:37.922834+00', NULL, '31b9861d-6ab4-40bc-9057-f6fde2b637b6'),
	('00000000-0000-0000-0000-000000000000', 84, 'stqy7bvnt5uz', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 00:21:53.196151+00', '2025-08-24 01:21:16.296417+00', NULL, '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 46, 'kgalb7kr3asf', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-20 10:21:40.44419+00', '2025-08-20 11:21:08.505433+00', NULL, '299d809d-c822-4aa0-9da8-c8bb1b7bc962'),
	('00000000-0000-0000-0000-000000000000', 47, '7xggzsh5zi3r', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', true, '2025-08-20 10:27:59.571735+00', '2025-08-20 11:27:25.291513+00', NULL, '086bd9dd-a5fe-49be-8bf0-2502bdfce59a'),
	('00000000-0000-0000-0000-000000000000', 85, 'bivfclcgmfmi', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 01:21:16.316781+00', '2025-08-24 02:20:45.808409+00', 'stqy7bvnt5uz', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 48, 'n7ckopclrequ', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-20 11:21:08.518826+00', '2025-08-20 12:20:38.272678+00', 'kgalb7kr3asf', '299d809d-c822-4aa0-9da8-c8bb1b7bc962'),
	('00000000-0000-0000-0000-000000000000', 50, '66o7veo7ybji', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-20 12:20:38.278867+00', '2025-08-20 12:20:38.278867+00', 'n7ckopclrequ', '299d809d-c822-4aa0-9da8-c8bb1b7bc962'),
	('00000000-0000-0000-0000-000000000000', 49, 'qvy6uguc7hdw', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', true, '2025-08-20 11:27:25.294265+00', '2025-08-20 12:26:54.597253+00', '7xggzsh5zi3r', '086bd9dd-a5fe-49be-8bf0-2502bdfce59a'),
	('00000000-0000-0000-0000-000000000000', 51, 'hzbppmhi3lgf', 'fa8dbca3-ce25-4cb4-be55-e412c88dc203', false, '2025-08-20 12:26:54.607402+00', '2025-08-20 12:26:54.607402+00', 'qvy6uguc7hdw', '086bd9dd-a5fe-49be-8bf0-2502bdfce59a'),
	('00000000-0000-0000-0000-000000000000', 87, '4mu5upz3r5rh', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 02:20:45.825803+00', '2025-08-24 03:20:14.54404+00', 'bivfclcgmfmi', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 88, 'hgmn55uf72jm', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 02:45:26.408441+00', '2025-08-24 03:44:55.863642+00', NULL, '5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b'),
	('00000000-0000-0000-0000-000000000000', 89, 'tsj4xswproij', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 03:20:14.565047+00', '2025-08-24 04:19:44.404406+00', '4mu5upz3r5rh', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 90, 'zc2fvoxuf676', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 03:44:55.87282+00', '2025-08-24 04:44:23.306459+00', 'hgmn55uf72jm', '5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b'),
	('00000000-0000-0000-0000-000000000000', 92, 'zlojb5win7jr', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 04:19:44.4112+00', '2025-08-24 05:19:14.484886+00', 'tsj4xswproij', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 93, 'njih27bgl2cw', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 04:44:23.317531+00', '2025-08-24 05:43:53.625693+00', 'zc2fvoxuf676', '5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b'),
	('00000000-0000-0000-0000-000000000000', 95, 'kbzhh54guehk', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 05:19:14.486332+00', '2025-08-24 06:18:44.497206+00', 'zlojb5win7jr', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 96, 'ckb7ut2qeorf', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 05:43:53.63483+00', '2025-08-24 06:43:23.571066+00', 'njih27bgl2cw', '5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b'),
	('00000000-0000-0000-0000-000000000000', 98, 'dqorfptckvh7', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 06:18:44.499736+00', '2025-08-24 07:18:14.665086+00', 'kbzhh54guehk', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 99, 'lvgfsafgdl36', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 06:43:23.580787+00', '2025-08-24 07:42:53.429709+00', 'ckb7ut2qeorf', '5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b'),
	('00000000-0000-0000-0000-000000000000', 123, 'o5o44sc4zq52', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-26 16:53:31.824588+00', '2025-08-26 17:52:57.354946+00', 'cf6x5oxtilhs', 'c27d859a-051b-474d-bdcd-be66afac813e'),
	('00000000-0000-0000-0000-000000000000', 125, '6mlyhlsbuzjm', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-26 18:52:22.025378+00', '2025-08-26 18:52:22.025378+00', 'uz35xtdec2e7', 'c27d859a-051b-474d-bdcd-be66afac813e'),
	('00000000-0000-0000-0000-000000000000', 127, 'kstgfc6nr2nj', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 08:55:39.167372+00', '2025-08-27 09:55:01.744567+00', NULL, 'fdba6f84-ad71-495a-817a-ac732530ae3e'),
	('00000000-0000-0000-0000-000000000000', 101, '3ufesixrndsz', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 07:18:14.667722+00', '2025-08-24 08:17:44.753464+00', 'dqorfptckvh7', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 129, 'vzlpwijzvgrh', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 10:54:30.616468+00', '2025-08-27 11:53:52.433716+00', 'azw4lifevdgt', 'fdba6f84-ad71-495a-817a-ac732530ae3e'),
	('00000000-0000-0000-0000-000000000000', 102, '57oniwqix6tu', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 07:42:53.433687+00', '2025-08-24 08:42:23.5747+00', 'lvgfsafgdl36', '5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b'),
	('00000000-0000-0000-0000-000000000000', 105, 'vpoyy7lloy4z', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-24 08:42:23.586476+00', '2025-08-24 08:42:23.586476+00', '57oniwqix6tu', '5b40298b-b7e6-4bf1-b6ae-f98f6b41be2b'),
	('00000000-0000-0000-0000-000000000000', 130, 'q5bjws4z7vrj', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-27 11:53:52.44194+00', '2025-08-27 11:53:52.44194+00', 'vzlpwijzvgrh', 'fdba6f84-ad71-495a-817a-ac732530ae3e'),
	('00000000-0000-0000-0000-000000000000', 104, 'awvdyrd3plzl', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 08:17:44.757819+00', '2025-08-24 09:17:14.959395+00', '3ufesixrndsz', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 131, '6icfldjfknjb', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 12:22:41.717454+00', '2025-08-27 13:22:02.950392+00', NULL, 'f42374b5-3902-4acb-a585-834f62e196f4'),
	('00000000-0000-0000-0000-000000000000', 107, 'ekslj3wosn5w', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 09:17:14.963906+00', '2025-08-24 10:16:45.095302+00', 'awvdyrd3plzl', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 108, 'tlpepljksm3n', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 10:16:45.11361+00', '2025-08-24 11:16:15.218473+00', 'ekslj3wosn5w', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 132, 'cwhspelzqfbu', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 13:22:02.963018+00', '2025-08-27 14:21:29.005125+00', '6icfldjfknjb', 'f42374b5-3902-4acb-a585-834f62e196f4'),
	('00000000-0000-0000-0000-000000000000', 109, 'pth3k33ttj4e', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 11:16:15.226969+00', '2025-08-24 12:15:45.528844+00', 'tlpepljksm3n', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 133, '7kvup5jwh6z7', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-27 14:21:29.02486+00', '2025-08-27 14:21:29.02486+00', 'cwhspelzqfbu', 'f42374b5-3902-4acb-a585-834f62e196f4'),
	('00000000-0000-0000-0000-000000000000', 134, 'ftt25plpi3us', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-27 14:24:42.091818+00', '2025-08-27 14:24:42.091818+00', NULL, '9fb4374a-a633-40bd-a646-fee354f3659a'),
	('00000000-0000-0000-0000-000000000000', 110, 'ea6sjhjwkx4p', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 12:15:45.545586+00', '2025-08-24 13:15:15.642886+00', 'pth3k33ttj4e', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 111, 'b4gq3kmqowsi', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 12:20:11.549641+00', '2025-08-24 13:19:34.380098+00', NULL, '2dd580e3-2101-4775-ac99-9b24ac3357d6'),
	('00000000-0000-0000-0000-000000000000', 135, 'uk6gbebvglbj', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 15:40:14.02918+00', '2025-08-27 16:39:39.937662+00', NULL, '9913afa5-63f0-4de2-a135-2665e13ec39d'),
	('00000000-0000-0000-0000-000000000000', 112, 'kzvj74xwrli3', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 13:15:15.655013+00', '2025-08-24 14:14:45.78637+00', 'ea6sjhjwkx4p', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 113, '4dwsjcjue4mc', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 13:19:34.383114+00', '2025-08-24 14:19:02.324083+00', 'b4gq3kmqowsi', '2dd580e3-2101-4775-ac99-9b24ac3357d6'),
	('00000000-0000-0000-0000-000000000000', 115, 'ttghc6zd5sxb', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-24 14:19:02.327352+00', '2025-08-24 14:19:02.327352+00', '4dwsjcjue4mc', '2dd580e3-2101-4775-ac99-9b24ac3357d6'),
	('00000000-0000-0000-0000-000000000000', 114, 'fhu2etvmpwqf', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-24 14:14:45.809003+00', '2025-08-25 00:38:27.609838+00', 'kzvj74xwrli3', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 116, 'gwfg7x7cp33p', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-25 00:38:27.627554+00', '2025-08-25 00:38:27.627554+00', 'fhu2etvmpwqf', '129375b0-87cc-41dd-825c-061caa0b8171'),
	('00000000-0000-0000-0000-000000000000', 136, 'zxwddpfrk66m', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 16:39:39.954356+00', '2025-08-27 17:39:05.638239+00', 'uk6gbebvglbj', '9913afa5-63f0-4de2-a135-2665e13ec39d'),
	('00000000-0000-0000-0000-000000000000', 117, '7yyhd5t6homx', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-26 12:24:55.933991+00', '2025-08-26 13:24:22.650408+00', NULL, 'a4738d6d-d200-4836-a9b4-9560e18553ea'),
	('00000000-0000-0000-0000-000000000000', 119, 'qh6n6vd3qf42', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-26 14:21:14.21501+00', '2025-08-26 14:21:14.21501+00', NULL, 'e81fb4c6-93a2-499f-9f44-0e592cf58802'),
	('00000000-0000-0000-0000-000000000000', 118, '3llynviru2vs', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-26 13:24:22.666671+00', '2025-08-26 14:23:45.77287+00', '7yyhd5t6homx', 'a4738d6d-d200-4836-a9b4-9560e18553ea'),
	('00000000-0000-0000-0000-000000000000', 120, 'ekin3nkhlxuh', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-26 14:23:45.785348+00', '2025-08-26 14:23:45.785348+00', '3llynviru2vs', 'a4738d6d-d200-4836-a9b4-9560e18553ea'),
	('00000000-0000-0000-0000-000000000000', 137, 'pxkb63fumafa', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 17:39:05.655117+00', '2025-08-27 18:38:30.022478+00', 'zxwddpfrk66m', '9913afa5-63f0-4de2-a135-2665e13ec39d'),
	('00000000-0000-0000-0000-000000000000', 121, '5xath3lbdedi', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-26 14:54:40.304908+00', '2025-08-26 15:54:06.668343+00', NULL, 'c27d859a-051b-474d-bdcd-be66afac813e'),
	('00000000-0000-0000-0000-000000000000', 122, 'cf6x5oxtilhs', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-26 15:54:06.679264+00', '2025-08-26 16:53:31.809038+00', '5xath3lbdedi', 'c27d859a-051b-474d-bdcd-be66afac813e'),
	('00000000-0000-0000-0000-000000000000', 138, 'dnbrepgi57e5', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 18:38:30.032423+00', '2025-08-27 19:37:55.751171+00', 'pxkb63fumafa', '9913afa5-63f0-4de2-a135-2665e13ec39d'),
	('00000000-0000-0000-0000-000000000000', 139, '63xyfvknp6mi', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 19:37:55.764364+00', '2025-08-27 20:37:23.981144+00', 'dnbrepgi57e5', '9913afa5-63f0-4de2-a135-2665e13ec39d'),
	('00000000-0000-0000-0000-000000000000', 141, '4plea42d5avx', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-27 20:37:24.004215+00', '2025-08-27 20:37:24.004215+00', '63xyfvknp6mi', '9913afa5-63f0-4de2-a135-2665e13ec39d'),
	('00000000-0000-0000-0000-000000000000', 142, 'xrzhddgimikq', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-27 20:46:09.03828+00', '2025-08-27 20:46:09.03828+00', NULL, 'ec7f35ea-83c2-42ab-a9f7-165a6178e925'),
	('00000000-0000-0000-0000-000000000000', 140, 'pjlvo2ki7nas', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 19:50:36.302035+00', '2025-08-27 20:50:55.900284+00', NULL, 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 143, '74fxetojqolr', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 20:50:55.902852+00', '2025-08-27 23:55:05.459296+00', 'pjlvo2ki7nas', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 144, '2agd6xz5ctan', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-27 23:55:05.473054+00', '2025-08-28 05:43:53.720316+00', '74fxetojqolr', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 147, 'nociiks2kvvf', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-28 15:52:05.916693+00', '2025-08-28 15:52:05.916693+00', NULL, '230eeee9-4b97-4b03-a0c1-fd7f41b3f2f6'),
	('00000000-0000-0000-0000-000000000000', 148, 'hpxmgcqwtwd7', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-28 22:16:20.080408+00', '2025-08-28 22:16:20.080408+00', NULL, '4f481247-2a34-4383-8c0b-d590f8a1eda4'),
	('00000000-0000-0000-0000-000000000000', 149, '45u2lzlnbekz', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-28 23:32:23.236588+00', '2025-08-28 23:32:23.236588+00', NULL, 'a2273ea1-6c30-420b-97a8-800c393801cb'),
	('00000000-0000-0000-0000-000000000000', 150, 'oif6v5r5ao2a', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-28 23:49:57.842429+00', '2025-08-29 00:49:24.011652+00', NULL, 'd974cb19-e60f-42ee-9970-ff129d7b9e98'),
	('00000000-0000-0000-0000-000000000000', 151, 'rzdzsfhwcil2', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-29 00:49:24.018544+00', '2025-08-29 01:48:46.471785+00', 'oif6v5r5ao2a', 'd974cb19-e60f-42ee-9970-ff129d7b9e98'),
	('00000000-0000-0000-0000-000000000000', 152, '2632gpnqjquu', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-29 01:48:46.496022+00', '2025-08-29 06:00:49.211341+00', 'rzdzsfhwcil2', 'd974cb19-e60f-42ee-9970-ff129d7b9e98'),
	('00000000-0000-0000-0000-000000000000', 145, 'imphncud7gol', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-28 04:44:55.736974+00', '2025-08-29 09:54:59.62161+00', NULL, 'de28c3ba-516c-4f22-82a5-22b1aa41d1be'),
	('00000000-0000-0000-0000-000000000000', 154, 'lnvxlp352bwj', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-29 09:54:59.644052+00', '2025-08-29 09:54:59.644052+00', 'imphncud7gol', 'de28c3ba-516c-4f22-82a5-22b1aa41d1be'),
	('00000000-0000-0000-0000-000000000000', 153, 'cnz46ggjjhxc', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-29 06:00:49.22334+00', '2025-08-29 10:02:06.983366+00', '2632gpnqjquu', 'd974cb19-e60f-42ee-9970-ff129d7b9e98'),
	('00000000-0000-0000-0000-000000000000', 155, 'tzqcl24csc4d', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-29 10:02:06.987133+00', '2025-08-29 10:02:06.987133+00', 'cnz46ggjjhxc', 'd974cb19-e60f-42ee-9970-ff129d7b9e98'),
	('00000000-0000-0000-0000-000000000000', 156, 'jdfcdnqxmpbk', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-29 11:52:46.630409+00', '2025-08-29 12:52:10.015561+00', NULL, '708c504d-5775-42c5-af06-947d11003056'),
	('00000000-0000-0000-0000-000000000000', 146, '3pvlnybjfvuv', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-28 05:43:53.736127+00', '2025-08-30 03:31:12.091704+00', '2agd6xz5ctan', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 157, 'u2pwcdhiagav', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-29 12:52:10.034206+00', '2025-08-29 12:52:10.034206+00', 'jdfcdnqxmpbk', '708c504d-5775-42c5-af06-947d11003056'),
	('00000000-0000-0000-0000-000000000000', 158, 'srwpi7txvj52', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-29 15:06:17.747697+00', '2025-08-29 15:06:17.747697+00', NULL, 'd52767a0-4246-448b-856b-a0173c401925'),
	('00000000-0000-0000-0000-000000000000', 159, 'wybx4rzpk3sq', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 02:15:57.7278+00', '2025-08-30 03:15:23.191126+00', NULL, 'e16a76ed-04c6-4b27-a6b0-e99cdfbb4bd8'),
	('00000000-0000-0000-0000-000000000000', 160, 'dxgxdarm5aai', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 03:15:23.206978+00', '2025-08-30 04:14:53.092861+00', 'wybx4rzpk3sq', 'e16a76ed-04c6-4b27-a6b0-e99cdfbb4bd8'),
	('00000000-0000-0000-0000-000000000000', 161, 'yxfck6pko5l5', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 03:31:12.098093+00', '2025-08-30 04:30:39.249402+00', '3pvlnybjfvuv', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 162, 'zqzrrhe4a4qp', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 04:14:53.109302+00', '2025-08-30 05:14:18.656069+00', 'dxgxdarm5aai', 'e16a76ed-04c6-4b27-a6b0-e99cdfbb4bd8'),
	('00000000-0000-0000-0000-000000000000', 164, '6toal3vorlps', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-30 05:14:18.667823+00', '2025-08-30 05:14:18.667823+00', 'zqzrrhe4a4qp', 'e16a76ed-04c6-4b27-a6b0-e99cdfbb4bd8'),
	('00000000-0000-0000-0000-000000000000', 163, '3k6eboddn2lx', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 04:30:39.255872+00', '2025-08-30 05:30:34.531016+00', 'yxfck6pko5l5', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 165, 'buuljktafhy4', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 05:30:34.543317+00', '2025-08-30 09:49:03.097311+00', '3k6eboddn2lx', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 166, '4rrkl4vbrhiu', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 09:49:03.124511+00', '2025-08-30 10:49:18.065079+00', 'buuljktafhy4', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 167, 'u4j74bdu26ho', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 09:53:08.751579+00', '2025-08-30 10:52:39.389219+00', '7ckbqpkvldrb', '07046f8c-cfd3-400f-8f89-96fe17a073de'),
	('00000000-0000-0000-0000-000000000000', 168, 'ijrsplgjzsow', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 10:49:18.070408+00', '2025-08-30 11:48:46.858492+00', '4rrkl4vbrhiu', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 169, 'hk2i2le2irnn', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 10:52:39.395831+00', '2025-08-30 11:52:06.664933+00', 'u4j74bdu26ho', '07046f8c-cfd3-400f-8f89-96fe17a073de'),
	('00000000-0000-0000-0000-000000000000', 170, 'olxsfsil4cnd', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 11:48:46.877575+00', '2025-08-30 12:48:07.256228+00', 'ijrsplgjzsow', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 171, 'gnb6qi3tmsgq', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 11:52:06.667513+00', '2025-08-30 12:51:26.796598+00', 'hk2i2le2irnn', '07046f8c-cfd3-400f-8f89-96fe17a073de'),
	('00000000-0000-0000-0000-000000000000', 174, 'w45aafvsxtu2', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-30 13:31:14.049142+00', '2025-08-30 13:31:14.049142+00', NULL, 'a45f280b-8338-4db6-8402-7e3d177305a4'),
	('00000000-0000-0000-0000-000000000000', 172, 's62upqxuvnhs', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 12:48:07.266561+00', '2025-08-30 13:47:33.552851+00', 'olxsfsil4cnd', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 173, 'wjo4dqd655by', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 12:51:26.799927+00', '2025-08-30 13:50:48.389083+00', 'gnb6qi3tmsgq', '07046f8c-cfd3-400f-8f89-96fe17a073de'),
	('00000000-0000-0000-0000-000000000000', 175, '2q4yuxkgxegq', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 13:47:33.570115+00', '2025-08-30 14:46:58.609909+00', 's62upqxuvnhs', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 176, 'fvmzlhzct5je', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 13:50:48.393162+00', '2025-08-30 14:50:13.675572+00', 'wjo4dqd655by', '07046f8c-cfd3-400f-8f89-96fe17a073de'),
	('00000000-0000-0000-0000-000000000000', 178, 'utxpln7yhwkj', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-30 14:50:13.676345+00', '2025-08-30 14:50:13.676345+00', 'fvmzlhzct5je', '07046f8c-cfd3-400f-8f89-96fe17a073de'),
	('00000000-0000-0000-0000-000000000000', 179, 'c3qvtppcq7e5', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-30 15:40:45.20818+00', '2025-08-30 15:40:45.20818+00', NULL, 'd425b9aa-54dc-40b9-881d-03ddce1e95c4'),
	('00000000-0000-0000-0000-000000000000', 177, 'bc7j3lufij73', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 14:46:58.631567+00', '2025-08-30 15:47:18.446465+00', '2q4yuxkgxegq', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 181, 'fmuem6eneahh', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-30 16:23:40.983886+00', '2025-08-30 16:23:40.983886+00', NULL, 'd6d256b0-c34a-4f84-917b-135c64e44e79'),
	('00000000-0000-0000-0000-000000000000', 180, 'rddbwgvqjean', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 15:47:18.449079+00', '2025-08-30 16:46:40.673991+00', 'bc7j3lufij73', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 182, 'kryqqvi43332', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 16:46:40.685287+00', '2025-08-30 17:46:06.276929+00', 'rddbwgvqjean', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 183, '5ulouhtgxvkv', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 17:46:06.29804+00', '2025-08-30 18:45:34.567735+00', 'kryqqvi43332', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 184, 'ejjxovvvqmmj', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-30 18:45:34.586926+00', '2025-08-31 13:59:38.171914+00', '5ulouhtgxvkv', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 185, 'jdzbqjwswjbh', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-31 13:59:38.186396+00', '2025-08-31 14:59:09.10703+00', 'ejjxovvvqmmj', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 186, 'a5rijfwyueai', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-31 14:59:09.134304+00', '2025-08-31 15:58:54.599305+00', 'jdzbqjwswjbh', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 187, 'p7az6yjgcy5u', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-31 15:58:54.617535+00', '2025-08-31 16:58:54.496262+00', 'a5rijfwyueai', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 188, 'dvzo2jlkd7xs', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-31 16:58:54.504791+00', '2025-08-31 17:58:54.894693+00', 'p7az6yjgcy5u', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 189, '6tdfcvydvwkd', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', true, '2025-08-31 17:58:54.911211+00', '2025-08-31 19:15:22.024042+00', 'dvzo2jlkd7xs', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1'),
	('00000000-0000-0000-0000-000000000000', 190, '26nwivggx737', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', false, '2025-08-31 19:15:22.04088+00', '2025-08-31 19:15:22.04088+00', '6tdfcvydvwkd', 'dc1a83c9-0bb1-443b-bc2c-5c65c02c29c1');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."categories" ("id", "name", "created_at", "parent_id") OVERRIDING SYSTEM VALUE VALUES
	(2, '생활용품', '2025-08-18 10:40:11.267969+00', NULL),
	(3, '신선식품', '2025-08-18 10:40:11.267969+00', NULL),
	(8, '주방용품', '2025-08-18 12:05:52.223548+00', NULL),
	(10, '거실용품', '2025-08-18 14:01:39.013592+00', 2),
	(13, '가전용품', '2025-08-18 14:08:19.215077+00', 10),
	(12, '가공식품ㅁㅁ', '2025-08-18 14:07:02.756291+00', 12),
	(14, '가공식품', '2025-08-18 14:22:27.814638+00', NULL),
	(15, '면류', '2025-08-18 14:32:28.788669+00', 14),
	(16, '라면', '2025-08-18 14:32:49.084886+00', 15),
	(17, '국수', '2025-08-18 14:32:56.759996+00', 15),
	(18, '농산물', '2025-08-18 15:08:04.745732+00', 3),
	(19, '과일', '2025-08-18 15:08:19.994647+00', 18),
	(20, '공동구매', '2025-08-23 18:29:03.17528+00', NULL),
	(21, '공구1', '2025-08-23 18:29:11.607982+00', 20),
	(22, '공구2', '2025-08-23 18:29:20.328425+00', 20),
	(26, '공구11', '2025-08-24 00:33:50.173257+00', 21);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."products" ("id", "name", "description", "image_url", "total_price", "source_url", "created_at", "category_id", "external_product_id", "is_displayed", "stock_quantity", "product_code", "related_product_code", "is_sold_out", "is_user_creatable", "shipping_fee", "tags", "discount_price", "discount_start_date", "discount_end_date") OVERRIDING SYSTEM VALUE VALUES
	(1, '햇반 이천쌀밥 210g 18개', '[{"insert": "맛있는 쌀로 만든 즉석밥입니다.\n"}]', 'https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/thumb-7J207LKc7IyA67Cl_M01_400x400.jpg', 25000, NULL, '2025-08-18 10:34:06.49367+00', NULL, NULL, true, 0, NULL, NULL, false, false, 3000, NULL, NULL, NULL, NULL),
	(4, '농심 안성탕면 20개', '[{"insert": "ㅁㅇㄹㄴㅁㅇㄹ\n"}]', 'https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/1755452612604.jpg', 15590, NULL, '2025-08-18 10:34:06.49367+00', NULL, NULL, true, 0, NULL, NULL, false, false, 3000, NULL, NULL, NULL, NULL),
	(5, '스팸마일드 340g X 6개', '[{"insert": "ㅇㅎ롱호\n"}]', 'https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/1755536003622.jpg', 33000, NULL, '2025-08-18 10:34:06.49367+00', 17, NULL, true, 0, NULL, NULL, false, false, 3000, NULL, NULL, NULL, NULL),
	(6, '농심 육개장 사발면', '[]', 'https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/1755992293216.jpg', 21000, NULL, '2025-08-23 21:46:30.734898+00', 16, NULL, true, 10, '234567', '456534', false, false, 3000, NULL, NULL, NULL, NULL),
	(3, '이가자연면 감자수제비 184g X 6', '"[{\"insert\":\"멸치육수로 우려낸 시원한 국물맛이 장점입니다.\\n\\n\"},{\"insert\":{\"image\":\"https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/1756530199546_thumb-6rCQ7J6Q7IiY7KCc67mE_m01_400x400.jpg\"}},{\"insert\":\"\\n\"}]"', 'https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/thumb-6rCQ7J6Q7IiY7KCc67mE_m01_400x400.jpg', 13990, NULL, '2025-08-18 10:34:06.49367+00', 17, NULL, true, 0, '12456', '234678', false, false, 3000, '{"is_recommended": true}', 12900, NULL, NULL),
	(8, '왕짜장', '"[{\"insert\":\"대박 아이템\",\"attributes\":{\"size\":\"huge\"}},{\"insert\":\"\\n\",\"attributes\":{\"align\":\"center\",\"header\":3}},{\"insert\":\"육개장 사발면을 5개\",\"attributes\":{\"size\":\"large\"}},{\"insert\":\"\\n\",\"attributes\":{\"indent\":2}},{\"insert\":\"\\n\"},{\"insert\":{\"image\":\"https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/1756520500090_7Jyh6rCc7J6l7IKs67Cc66m0_m01.jpg\"}},{\"insert\":\"\\n\"}]"', 'https://oyoznvosuyxhgxmbfaow.supabase.co/storage/v1/object/public/products/1756305550484.jpg', 12500, NULL, '2025-08-27 14:39:12.918127+00', 16, NULL, true, 1000, '123123', '456654', false, false, 3500, '{"is_hit": true, "is_new": true}', 11000, '2025-08-30 00:00:00+00', '2025-09-18 00:00:00+00');


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."cart_items" ("id", "created_at", "user_id", "product_id", "quantity") VALUES
	(1, '2025-08-24 01:57:18.985582+00', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', 3, 1),
	(2, '2025-08-24 02:03:01.46966+00', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', 6, 2);


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "username", "avatar_url", "created_at", "phone", "level", "points", "fcm_token", "nickname", "phone_number", "address", "full_name") VALUES
	('a02687a3-3ef8-4389-acc7-5d05e8d24537', 'gruto@naver.com', NULL, '2025-08-20 20:28:20.162383+00', NULL, 10, 0, 'cPuqVOJASfeppcIiepf2jo:APA91bHKcJRhDMxa8yNFAl9sxU6p5FYI58ZOtwXx53Ry7ffK0doK5t_FDYAlNzn515syI32DpNDyGE53iLlUZKgHomHyTnVRfsDxLccKpO0l64q00Z8HAVY', NULL, NULL, NULL, NULL),
	('53107d9e-72e2-4a6b-8ed5-ab4f31e4c2c3', 'bb@bb.com', NULL, '2025-08-20 18:20:04.422113+00', NULL, 2, 0, NULL, NULL, NULL, NULL, NULL),
	('fa8dbca3-ce25-4cb4-be55-e412c88dc203', 'ab@aa.com', NULL, '2025-08-19 16:28:23.435544+00', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL),
	('53b52c67-3224-4570-883c-ac36fe180b66', 'cc@cc.com', NULL, '2025-08-20 18:16:13.06146+00', NULL, 2, 0, NULL, NULL, NULL, NULL, NULL),
	('3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', 'aa@aa.com', NULL, '2025-08-19 16:47:55.513841+00', NULL, 10, 340, NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: group_buys; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."group_buys" ("id", "host_id", "product_id", "target_participants", "current_participants", "status", "created_at", "expires_at", "deadline") OVERRIDING SYSTEM VALUE VALUES
	(36, '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', 5, 6, 6, 'preparing', '2025-08-20 21:27:30.738248+00', '2025-08-23 23:59:59+00', '2025-08-23');


--
-- Data for Name: inquiries; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."participants" ("id", "group_buy_id", "user_id", "delivery_address", "payment_status", "tracking_number", "joined_at", "quantity") OVERRIDING SYSTEM VALUE VALUES
	(66, 36, '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '기본 배송지', 'pending', NULL, '2025-08-20 21:27:30.738248+00', 2),
	(68, 36, 'a02687a3-3ef8-4389-acc7-5d05e8d24537', '기본 배송지', 'pending', NULL, '2025-08-20 22:54:33.510373+00', 4);


--
-- Data for Name: product_option_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."product_option_groups" ("id", "product_id", "name") VALUES
	(21, 3, '갯수'),
	(26, 8, '종류'),
	(27, 8, '사이즈');


--
-- Data for Name: product_option_values; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."product_option_values" ("id", "option_group_id", "value") VALUES
	(64, 26, '봉지면'),
	(65, 26, '용기면'),
	(66, 27, '대'),
	(67, 27, '중'),
	(68, 27, '소'),
	(51, 21, '1'),
	(52, 21, '3'),
	(53, 21, '5');


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."product_variants" ("id", "product_id", "name", "additional_price", "stock_quantity") VALUES
	(61, 3, '1', -1000, 0),
	(62, 3, '3', -500, 0),
	(63, 3, '5', -200, 0),
	(76, 8, '봉지면 / 대', 200, 0),
	(77, 8, '봉지면 / 중', 150, 0),
	(78, 8, '봉지면 / 소', 100, 0),
	(79, 8, '용기면 / 대', 100, 0),
	(80, 8, '용기면 / 중', 50, 0),
	(81, 8, '용기면 / 소', 0, 0);


--
-- Data for Name: promotions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: proposals; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: reply_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."settings" ("key", "value", "comment", "created_at", "updated_at") VALUES
	('shipping_fee', '3000', '기본 배송비', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('company_name', '(주)나눔', '회사명', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('business_number', '123-45-67890', '사업자 등록번호', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('ceo_name', '홍길동', '대표자 이름', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('address', '서울특별시 강남구 테헤란로 123', '사업장 주소', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('telecommunication_sales_number', '2025-서울강남-01234', '통신판매업 신고번호', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('customer_service_phone', '1588-0000', '고객센터 전화번호', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('customer_service_email', 'help@nanum.com', '고객센터 이메일', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00'),
	('logo_image_url', '', '쇼핑몰 로고 이미지 URL (비워두면 텍스트 로고 사용)', '2025-08-29 00:14:19.324415+00', '2025-08-29 00:14:19.324415+00');


--
-- Data for Name: wishlist_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('products', 'products', NULL, '2025-08-17 16:42:07.117789+00', '2025-08-17 16:42:07.117789+00', true, false, NULL, NULL, NULL, 'STANDARD');


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata", "level") VALUES
	('3fccdbcd-1563-4d1a-8163-fadee331a5f0', 'products', 'thumb-6rCQ7J6Q7IiY7KCc67mE_m01_400x400.jpg', NULL, '2025-08-17 16:54:54.834661+00', '2025-08-17 16:54:54.834661+00', '2025-08-17 16:54:54.834661+00', '{"eTag": "\"ce7b38a8d5f390149906cd1e90dc3243-1\"", "size": 34756, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-17T16:54:55.000Z", "contentLength": 34756, "httpStatusCode": 200}', 'd0577a8a-f829-449e-8301-23783abb230b', NULL, NULL, 1),
	('560c701a-a3b1-4e85-89bf-61b0d48ee084', 'products', '7Jyh6rCc7J6l7IKs67Cc66m0_m01.jpg', NULL, '2025-08-17 16:55:40.208185+00', '2025-08-17 16:55:40.208185+00', '2025-08-17 16:55:40.208185+00', '{"eTag": "\"b2dd64a6017e2e464b169d7702854d9c-1\"", "size": 256379, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-17T16:55:40.000Z", "contentLength": 256379, "httpStatusCode": 200}', 'bf0e17d0-f749-4b8a-8d1e-032ec66030e0', NULL, NULL, 1),
	('af32de84-128d-4ab2-a1d7-194da5394c82', 'products', 'thumb-7J207LKc7IyA67Cl_M01_400x400.jpg', NULL, '2025-08-17 16:56:02.775657+00', '2025-08-17 16:56:02.775657+00', '2025-08-17 16:56:02.775657+00', '{"eTag": "\"1c251d3555e76c4d74aadebf4e66539a-1\"", "size": 31172, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-17T16:56:03.000Z", "contentLength": 31172, "httpStatusCode": 200}', 'd1a54f45-6bdd-4a35-b4f0-033184c37627', NULL, NULL, 1),
	('e436f937-3edc-4b39-8113-50d5eada9ac7', 'products', '1755452612604.jpg', '1b648960-b270-4fd3-b4f8-59c9f98c5522', '2025-08-17 17:43:33.44666+00', '2025-08-17 17:43:33.44666+00', '2025-08-17 17:43:33.44666+00', '{"eTag": "\"ce2a35b988501194ba6d8ef6132f6a11\"", "size": 289595, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2025-08-17T17:43:34.000Z", "contentLength": 289595, "httpStatusCode": 200}', '4917376b-9c6d-4a06-926f-793c2f482f33', '1b648960-b270-4fd3-b4f8-59c9f98c5522', '{}', 1),
	('2dbb588b-f5b4-4981-9bf2-a1901250aa80', 'products', '1755454038515.jpg', '1b648960-b270-4fd3-b4f8-59c9f98c5522', '2025-08-17 18:07:19.476642+00', '2025-08-17 18:07:19.476642+00', '2025-08-17 18:07:19.476642+00', '{"eTag": "\"f5c80146e2db4f371f3c6c8b31c80459\"", "size": 192424, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2025-08-17T18:07:20.000Z", "contentLength": 192424, "httpStatusCode": 200}', 'f01b11a4-8358-427f-a006-1bbb3bce1fea', '1b648960-b270-4fd3-b4f8-59c9f98c5522', '{}', 1),
	('f56a25ec-a62e-420c-b58a-73f1a4cfb74e', 'products', '1755536003622.jpg', NULL, '2025-08-18 16:53:25.965288+00', '2025-08-18 16:53:25.965288+00', '2025-08-18 16:53:25.965288+00', '{"eTag": "\"f5c80146e2db4f371f3c6c8b31c80459\"", "size": 192424, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2025-08-18T16:53:26.000Z", "contentLength": 192424, "httpStatusCode": 200}', '4f6a02bc-28f2-4362-8f0f-c3179741e797', NULL, '{}', 1),
	('8178ff65-58ec-45d3-85e6-b150ba670583', 'products', '1755536214190.jpg', NULL, '2025-08-18 16:56:56.769909+00', '2025-08-18 16:56:56.769909+00', '2025-08-18 16:56:56.769909+00', '{"eTag": "\"7fded8b5cb9b886ab34c5084741fd298\"", "size": 256379, "mimetype": "image/jpg", "cacheControl": "max-age=3600", "lastModified": "2025-08-18T16:56:57.000Z", "contentLength": 256379, "httpStatusCode": 200}', '024c8fb7-5804-43d7-a5b8-2aa8d789fefc', NULL, '{}', 1),
	('3d592ad9-c85a-4795-ab3f-ddc26f38a570', 'products', '1755992293216.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-23 23:38:13.422908+00', '2025-08-23 23:38:13.422908+00', '2025-08-23 23:38:13.422908+00', '{"eTag": "\"7fded8b5cb9b886ab34c5084741fd298\"", "size": 256379, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-23T23:38:14.000Z", "contentLength": 256379, "httpStatusCode": 200}', 'abff183b-9b4a-43b4-8841-918d16e5177f', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1),
	('48c9d2b1-84f4-499a-b85d-0573e2d36514', 'products', '1756305550484.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-27 14:39:12.67264+00', '2025-08-27 14:39:12.67264+00', '2025-08-27 14:39:12.67264+00', '{"eTag": "\"c36187d0b98649c33f7f3d6ed192b686\"", "size": 327450, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-27T14:39:13.000Z", "contentLength": 327450, "httpStatusCode": 200}', 'f5063a80-0b76-45d1-aea6-dad7808ca220', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1),
	('f547ff39-199b-4b5f-bb1b-4a21720a880e', 'products', '1756481193542_7JWI7ISx7YOV66m0_m01.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-29 15:26:34.344925+00', '2025-08-29 15:26:34.344925+00', '2025-08-29 15:26:34.344925+00', '{"eTag": "\"ce2a35b988501194ba6d8ef6132f6a11\"", "size": 289595, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-29T15:26:35.000Z", "contentLength": 289595, "httpStatusCode": 200}', '8e7b8858-c963-47e8-bf13-9f71460b72f5', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1),
	('5f47e002-471d-407a-9b71-0d098b8b6f5b', 'products', '1756481252730_7Jyh6rCc7J6l7IKs67Cc66m0_m01.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-29 15:27:33.616259+00', '2025-08-29 15:27:33.616259+00', '2025-08-29 15:27:33.616259+00', '{"eTag": "\"7fded8b5cb9b886ab34c5084741fd298\"", "size": 256379, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-29T15:27:34.000Z", "contentLength": 256379, "httpStatusCode": 200}', '74f762c6-00cb-4a5f-be9c-eee77b6f9b76', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1),
	('d6666821-4280-434d-a77a-8eb163c9d68d', 'products', '1756481309701_thumb-7J207LKc7IyA67Cl_M01_400x400.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-29 15:28:30.187928+00', '2025-08-29 15:28:30.187928+00', '2025-08-29 15:28:30.187928+00', '{"eTag": "\"3e488c6470da335fc625c169d85ad7dc\"", "size": 31172, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-29T15:28:31.000Z", "contentLength": 31172, "httpStatusCode": 200}', '3703b567-2648-4739-9ee3-d54757026eb4', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1),
	('53ae32df-226a-43f8-b74b-c3af3a551622', 'products', '1756481358152_7IOI7Jqw7YOV7YqA6rmA7Jqw64Z_m01.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-29 15:29:18.963778+00', '2025-08-29 15:29:18.963778+00', '2025-08-29 15:29:18.963778+00', '{"eTag": "\"c36187d0b98649c33f7f3d6ed192b686\"", "size": 327450, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-29T15:29:19.000Z", "contentLength": 327450, "httpStatusCode": 200}', '951ddefa-a88b-4ea2-b1c3-ed5e4835d712', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1),
	('e5c4c896-bf97-40df-bd1d-1b735279ad6c', 'products', '1756520500090_7Jyh6rCc7J6l7IKs67Cc66m0_m01.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-30 02:21:41.264097+00', '2025-08-30 02:21:41.264097+00', '2025-08-30 02:21:41.264097+00', '{"eTag": "\"7fded8b5cb9b886ab34c5084741fd298\"", "size": 256379, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-30T02:21:42.000Z", "contentLength": 256379, "httpStatusCode": 200}', '49349cdf-1112-456d-a8cf-4d75aa4accbe', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1),
	('000e4f2a-396f-4142-98cf-788288280606', 'products', '1756530199546_thumb-6rCQ7J6Q7IiY7KCc67mE_m01_400x400.jpg', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '2025-08-30 05:03:21.008134+00', '2025-08-30 05:03:21.008134+00', '2025-08-30 05:03:21.008134+00', '{"eTag": "\"9ca2e3a1077a1f27658c8a738fc1a5cb\"", "size": 34756, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-08-30T05:03:21.000Z", "contentLength": 34756, "httpStatusCode": 200}', '5c53ef01-442a-4565-8f44-282a027b556a', '3c77d26b-f6f4-4a0a-b026-7b89faa9cb26', '{}', 1);


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

INSERT INTO "supabase_functions"."hooks" ("id", "hook_table_id", "hook_name", "created_at", "request_id") VALUES
	(1, 17348, 'on_status_change_send_notification', '2025-08-20 20:59:11.933934+00', 1),
	(2, 17348, 'on_status_change_send_notification', '2025-08-20 21:01:08.690144+00', 2),
	(3, 17348, 'on_status_change_send_notification', '2025-08-20 21:13:22.228774+00', 3),
	(4, 17348, 'on_status_change_send_notification', '2025-08-20 21:13:38.307854+00', 4),
	(5, 17348, 'on_status_change_send_notification', '2025-08-20 21:16:11.848681+00', 5),
	(6, 17348, 'on_status_change_send_notification', '2025-08-20 21:16:54.801632+00', 6),
	(7, 17348, 'on_status_change_send_notification', '2025-08-20 22:18:58.387433+00', 7),
	(8, 17348, 'on_status_change_send_notification', '2025-08-20 22:19:40.538682+00', 8),
	(9, 17348, 'on_status_change_send_notification', '2025-08-20 22:19:52.84231+00', 9),
	(10, 17348, 'on_status_change_send_notification', '2025-08-20 22:21:58.2061+00', 10),
	(11, 17348, 'on_status_change_send_notification', '2025-08-20 22:22:21.562371+00', 11),
	(12, 17348, 'on_status_change_send_notification', '2025-08-20 22:54:33.510373+00', 12),
	(13, 17348, 'on_status_change_send_notification', '2025-08-20 22:54:47.187682+00', 13),
	(14, 17348, 'on_status_change_send_notification', '2025-08-20 23:01:48.611686+00', 14),
	(15, 17348, 'on_status_change_send_notification', '2025-08-20 23:07:33.826394+00', 15),
	(16, 17348, 'on_status_change_send_notification', '2025-08-20 23:32:50.07408+00', 16),
	(17, 17348, 'on_status_change_send_notification', '2025-08-20 23:36:50.047021+00', 17),
	(18, 17348, 'on_status_change_send_notification', '2025-08-20 23:38:16.598435+00', 18),
	(19, 17348, 'on_status_change_send_notification', '2025-08-20 23:38:57.584012+00', 19);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 190, true);


--
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."cart_items_id_seq"', 3, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."categories_id_seq"', 83, true);


--
-- Name: group_buys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."group_buys_id_seq"', 36, true);


--
-- Name: inquiries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."inquiries_id_seq"', 1, false);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."order_items_id_seq"', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."orders_id_seq"', 1, false);


--
-- Name: participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."participants_id_seq"', 68, true);


--
-- Name: product_option_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."product_option_groups_id_seq"', 27, true);


--
-- Name: product_option_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."product_option_values_id_seq"', 68, true);


--
-- Name: product_variants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."product_variants_id_seq"', 81, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."products_id_seq"', 8, true);


--
-- Name: promotions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."promotions_id_seq"', 1, false);


--
-- Name: proposals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."proposals_id_seq"', 3, true);


--
-- Name: reply_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."reply_templates_id_seq"', 1, false);


--
-- Name: wishlist_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."wishlist_items_id_seq"', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 19, true);


--
-- PostgreSQL database dump complete
--

RESET ALL;
