import { Router } from "express";
import { db } from "../config/db.js";

const router = Router();

router.get('/health', (_req, res) => {
    res.status(200).json({
            ok: true,
            message: "USD backend is running",
    });
});

router.get('/db-check', async (_req, res) => {
    try {
        const result = await db.query('SELECT NOW() AS now');

        res.status(200).json({
            ok: true,
            db: "connected",
            now: result.rows[0]?.now,
        })
    } catch (error) {
        res.status(500).json({
            ok: false,
            db: "disconnected",
            message: error instanceof Error ? error.message : "Unknown database error",
        });
    }
});

export default router;